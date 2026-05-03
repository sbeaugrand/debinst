/******************************************************************************!
 * \file main.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note https://github.com/raspberrypi/pico-examples/tree/master/pio/hello_pio
 ******************************************************************************/
#include <hardware/pio.h>
#include "rc-switch.pio.h"
#include "CH9120.h"

#define PIN 22
#define FREQ 250000  // 136 / (11 + 15 + 8) = 4 us

extern UCHAR CH9120_Mode;

PIO gPio;
uint gSm;

void send(uint32_t k)
{
    pio_sm_put_blocking(gPio, gSm, ~k << (32 - rc_switch_LEN));
    sleep_us(1000 + rc_switch_LEN * 136);
    pio_sm_put_blocking(gPio, gSm, ~k << (32 - rc_switch_LEN));
    sleep_us(1000 + rc_switch_LEN * 136);
    pio_sm_put_blocking(gPio, gSm, ~k << (32 - rc_switch_LEN));
    sleep_us(1000 + rc_switch_LEN * 136);
}

int
main()
{
    uint offset;
    uint32_t k = 0;

    bool success =
        pio_claim_free_sm_and_add_program_for_gpio_range(
            &rc_switch_program, &gPio, &gSm, &offset, PIN, 1, true);
    hard_assert(success);
    rc_switch_program_init(gPio, gSm, offset, PIN, FREQ);

    CH9120_Mode = TCP_SERVER;
    CH9120_init();

    for (;;) {
        if (uart_is_readable(UART_ID1)) {
            uint8_t c = uart_getc(UART_ID1);
            if (c >= '0' &&
                c <= '9') {
                k = k * 10 + c - '0';
            } else if (c == '\n') {
                if (k & 0xfe000000u) {
                    if (uart_is_writable(UART_ID1)) {
                        static char msg[16];
                        sprintf(msg, "0x%08x ko\n", k);
                        uart_puts(UART_ID1, msg);
                    }
                } else {
                    send(k);
                    if (uart_is_writable(UART_ID1)) {
                        static char msg[16];
                        sprintf(msg, "0x%08x ok\n", k);
                        uart_puts(UART_ID1, msg);
                    }
                }
                k = 0;
            }
        }
    }
}
