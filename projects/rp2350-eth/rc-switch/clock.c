/******************************************************************************!
 * \file clock.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note 2 x DC56-11EWA (common cathode), segments a..g,dp on SEG_PIN..+7
 *       (resistor on each segment), digit cathodes through NPN transistors
 *       (emitter to ground) on DIG_PIN..+3, digit 0 = tens of hours
 ******************************************************************************/
#include <string.h>
#include <hardware/sync.h>
#include "CH9120.h"
#include "clock.h"

#define SEG_PIN 0
#define DIG_PIN 8
#define SEG_MASK (0xffu << SEG_PIN)
#define DIG_MASK (0x0fu << DIG_PIN)
#define MUX_PERIOD_US 2500  // 100 Hz per digit

#define NTP_SERVER 162, 159, 200, 1  // time.cloudflare.com (anycast)
#define NTP_PORT 123
#define NTP_UNIX_OFFSET 2208988800u
#define NTP_TIMEOUT_US 2000000
#define NTP_RETRIES 5

#define TZ_OFFSET 3600  // CET, CEST with european rules

#define SEG_DP    0x80
#define SEG_MINUS 0x40

// Variables and functions of CH9120.c not declared in CH9120.h
extern UCHAR CH9120_Mode;
extern UCHAR CH9120_TARGET_IP[4];
extern UWORD CH9120_TARGET_PORT;
void CH9120_Start(void);
void CH9120_End(void);
void CH9120_SetMode(UCHAR mode);
void CH9120_SetTargetIP(UCHAR ip[]);
void CH9120_SetTargetPort(UWORD port);

static const uint8_t gFont[10] = {
    0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f
};

static volatile bool gSynced = false;
static uint64_t gOffsetUs;  // unix time in us = time_us_64() + gOffsetUs
static repeating_timer_t gTimer;

/******************************************************************************!
 * \fn isDst
 * \brief European summer time : from last sunday of march 1:00 UTC
 *        to last sunday of october 1:00 UTC
 ******************************************************************************/
static bool
isDst(int month, int mday, int wday, int hour)
{
    if (month > 3 && month < 10) {
        return true;
    }
    if (month != 3 && month != 10) {
        return false;
    }
    int lastSunday = 31 - (wday + 31 - mday) % 7;
    bool after = mday > lastSunday || (mday == lastSunday && hour >= 1);
    return (month == 3) ? after : ! after;
}

/******************************************************************************!
 * \fn localTime
 ******************************************************************************/
static void
localTime(uint64_t unixSec, int* hour, int* min, int* sec)
{
    uint32_t days = unixSec / 86400;
    uint32_t secs = unixSec % 86400;
    int wday = (days + 4) % 7;  // 1970-01-01 is a thursday, sunday = 0

    // civil_from_days (H. Hinnant)
    uint32_t z = days + 719468;
    uint32_t era = z / 146097;
    uint32_t doe = z - era * 146097;
    uint32_t yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    uint32_t doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    uint32_t mp = (5 * doy + 2) / 153;
    int mday = doy - (153 * mp + 2) / 5 + 1;
    int month = mp < 10 ? mp + 3 : mp - 9;

    uint32_t t = secs + TZ_OFFSET;
    if (isDst(month, mday, wday, secs / 3600)) {
        t += 3600;
    }
    t %= 86400;
    *hour = t / 3600;
    *min = t / 60 % 60;
    *sec = t % 60;
}

/******************************************************************************!
 * \fn updateDigits
 ******************************************************************************/
static void
updateDigits(uint8_t segs[4])
{
    if (! gSynced) {
        memset(segs, SEG_MINUS, 4);
        return;
    }
    int hour, min, sec;
    localTime((time_us_64() + gOffsetUs) / 1000000, &hour, &min, &sec);
    segs[0] = hour >= 10 ? gFont[hour / 10] : 0;
    segs[1] = gFont[hour % 10] | ((sec & 1) ? SEG_DP : 0);
    segs[2] = gFont[min / 10];
    segs[3] = gFont[min % 10];
}

/******************************************************************************!
 * \fn mux
 ******************************************************************************/
static bool
mux(repeating_timer_t* rt)
{
    static uint digit = 0;
    static uint8_t segs[4];

    (void) rt;
    gpio_put_masked(DIG_MASK, 0);
    if (digit == 0) {
        updateDigits(segs);
    }
    gpio_put_masked(SEG_MASK, (uint32_t) segs[digit] << SEG_PIN);
    gpio_put_masked(DIG_MASK, 1u << (DIG_PIN + digit));
    digit = (digit + 1) & 3;
    return true;
}

/******************************************************************************!
 * \fn clock_init
 ******************************************************************************/
void
clock_init(void)
{
    gpio_init_mask(SEG_MASK | DIG_MASK);
    gpio_clr_mask(SEG_MASK | DIG_MASK);
    gpio_set_dir_out_masked(SEG_MASK | DIG_MASK);
    for (uint pin = SEG_PIN; pin < SEG_PIN + 8; ++pin) {
        gpio_set_drive_strength(pin, GPIO_DRIVE_STRENGTH_8MA);
    }
    add_repeating_timer_us(-MUX_PERIOD_US, mux, NULL, &gTimer);
}

/******************************************************************************!
 * \fn configure
 ******************************************************************************/
static void
configure(UCHAR mode)
{
    uart_set_baudrate(UART_ID1, Inti_BAUD_RATE);
    CH9120_Start();
    CH9120_SetMode(mode);
    CH9120_SetTargetIP(CH9120_TARGET_IP);
    CH9120_SetTargetPort(CH9120_TARGET_PORT);
    CH9120_End();
    uart_set_baudrate(UART_ID1, Transport_BAUD_RATE);
    while (uart_is_readable(UART_ID1)) {
        uart_getc(UART_ID1);
    }
}

/******************************************************************************!
 * \fn be32
 ******************************************************************************/
static uint32_t
be32(const uint8_t* p)
{
    return (uint32_t) p[0] << 24 | (uint32_t) p[1] << 16 |
           (uint32_t) p[2] << 8 | p[3];
}

/******************************************************************************!
 * \fn clock_sync
 * \brief CH9120 has only one socket : switch temporarily to UDP client
 *        to query the NTP server, then back to TCP server
 ******************************************************************************/
bool
clock_sync(void)
{
    static UCHAR server[4] = { NTP_SERVER };
    UCHAR savedIp[4];
    UWORD savedPort = CH9120_TARGET_PORT;
    uint8_t pkt[48];
    bool ok = false;

    memcpy(savedIp, CH9120_TARGET_IP, 4);
    memcpy(CH9120_TARGET_IP, server, 4);
    CH9120_TARGET_PORT = NTP_PORT;
    configure(UDP_CLIENT);

    for (int retry = 0; retry < NTP_RETRIES && ! ok; ++retry) {
        memset(pkt, 0, sizeof(pkt));
        pkt[0] = 0x1b;  // LI 0, version 3, mode 3 (client)
        uint64_t t0 = time_us_64();
        uart_write_blocking(UART_ID1, pkt, sizeof(pkt));
        uint n = 0;
        while (n < sizeof(pkt) && time_us_64() - t0 < NTP_TIMEOUT_US) {
            if (uart_is_readable(UART_ID1)) {
                pkt[n++] = uart_getc(UART_ID1);
            }
        }
        uint64_t t1 = time_us_64();
        if (n == sizeof(pkt) && (pkt[0] & 7) == 4 && pkt[1] != 0) {
            uint32_t sec = be32(pkt + 40) - NTP_UNIX_OFFSET;
            uint64_t us = (uint64_t) sec * 1000000 +
                          (((uint64_t) be32(pkt + 44) * 1000000) >> 32) +
                          (t1 - t0) / 2;
            uint32_t irq = save_and_disable_interrupts();
            gOffsetUs = us - t1;
            gSynced = true;
            restore_interrupts(irq);
            ok = true;
        }
    }

    memcpy(CH9120_TARGET_IP, savedIp, 4);
    CH9120_TARGET_PORT = savedPort;
    configure(CH9120_Mode);
    return ok;
}
