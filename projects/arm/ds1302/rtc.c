/******************************************************************************!
 * \file rtc.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "ds1302.h"
#include "wiring.h"

#define PIN_CLK 23
#define PIN_DAT 21
#define PIN_RST 19

// wiringPi/devLib/ds1302.c
#define RTC_SECS 0
#define RTC_MINS 1
#define RTC_HOURS 2
#define RTC_DATE 3
#define RTC_MONTH 4
#define RTC_DAY 5
#define RTC_YEAR 6
#define RTC_WP 7

//#define BCD2HEX(a) ((a) % 16 + (a) / 16 * 10)
//#define HEX2BCD(a) ((a) % 10 + (a) / 10 * 16)
#define BCD2HEX(a, b) (((a) & 0x0F) + (((a) & (b)) >> 4) * 10)
#define HEX2BCD(a, b) (((b) - '0') + (((a) - '0') << 4))

/******************************************************************************!
 * \fn setDSclock
 ******************************************************************************/
int setDSclock(char* date)
{
    int clock[8];

    // date +%FT%Tw%w
    // YYYY-mm-ddTHH:MM:SSww
    clock[RTC_SECS] = HEX2BCD(date[17], date[18]);
    clock[RTC_MINS] = HEX2BCD(date[14], date[15]);
    clock[RTC_HOURS] = HEX2BCD(date[11], date[12]);
    clock[RTC_DATE] = HEX2BCD(date[8], date[9]);
    clock[RTC_MONTH] = HEX2BCD(date[5], date[6]);
    clock[RTC_YEAR] = HEX2BCD(date[2], date[3]);
    clock[RTC_WP] = 0;
    clock[RTC_DAY] = date[20] - '0';

    ds1302clockWrite(clock);
    ds1302rtcWrite(RTC_WP, 1);

    return 0;
}

/******************************************************************************!
 * \fn setLinuxClock
 ******************************************************************************/
int setLinuxClock()
{
    char command[32];
    int clock[8];

    ds1302clockRead(clock);
#   ifndef NDEBUG
    fprintf(stdout, "%d %d %d %d %d %d\n",
            clock[RTC_MONTH],
            clock[RTC_DATE],
            clock[RTC_HOURS],
            clock[RTC_MINS],
            clock[RTC_YEAR],
            clock[RTC_SECS]);
#   endif

    // MMDDhhmm[[CC]YY][.ss]
    sprintf(command, "/bin/date %02d%02d%02d%02d20%02d.%02d",
            BCD2HEX(clock[RTC_MONTH], 0x1F),
            BCD2HEX(clock[RTC_DATE], 0x3F),
            BCD2HEX(clock[RTC_HOURS], 0x3F),
            BCD2HEX(clock[RTC_MINS], 0x7F),
            BCD2HEX(clock[RTC_YEAR], 0xFF),
            BCD2HEX(clock[RTC_SECS], 0x7F));

    fprintf(stdout, "%s\n", command);

    return system(command);
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main(int argc, char* argv[])
{
    int ret;

    ds1302setup(PIN_CLK, PIN_DAT, PIN_RST);

    if (argc == 2) {
        ret = setDSclock(argv[1]);
    } else {
        ret = setLinuxClock();
    }
    if (ret != 0) {
        return EXIT_FAILURE;
    }

    digitalQuit(PIN_CLK);
    digitalQuit(PIN_DAT);
    digitalQuit(PIN_RST);

    return EXIT_SUCCESS;
}
