/******************************************************************************!
 * \file wiringPi.c
 * \author Gordon Henderson
 * \sa http://beaugrand.chez.com/
 * \copyright GNU LGPLv3
 * \note Not modified functions from :
         https://github.com/WiringPi/WiringPi/blob/master/wiringPi/wiringPi.c
 ******************************************************************************/
/*
 * wiringPi:
 * Arduino look-a-like Wiring library for the Raspberry Pi
 * Copyright (c) 2012-2017 Gordon Henderson
 * Additional code for pwmSetClock by Chris Hall <chris@kchall.plus.com>
 *
 * Thanks to code samples from Gert Jan van Loo and the
 * BCM2835 ARM Peripherals manual, however it's missing
 * the clock section /grr/mutter/
 ***********************************************************************
 * This file is part of wiringPi:
 * https://projects.drogon.net/raspberry-pi/wiringpi/
 *
 *    wiringPi is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU Lesser General Public License as
 *    published by the Free Software Foundation, either version 3 of the
 *    License, or (at your option) any later version.
 *
 *    wiringPi is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with wiringPi.
 *    If not, see <http://www.gnu.org/licenses/>.
 ***********************************************************************
 */
#include <stddef.h>
#include <time.h>
#include <sys/time.h>

/*
 * delayMicroseconds:
 * This is somewhat intersting. It seems that on the Pi, a single call
 * to nanosleep takes some 80 to 130 microseconds anyway, so while
 * obeying the standards (may take longer), it's not always what we
 * want!
 *
 * So what I'll do now is if the delay is less than 100uS we'll do it
 * in a hard loop, watching a built-in counter on the ARM chip. This is
 * somewhat sub-optimal in that it uses 100% CPU, something not an issue
 * in a microcontroller, but under a multi-tasking, multi-user OS, it's
 * wastefull, however we've no real choice )-:
 *
 *      Plan B: It seems all might not be well with that plan, so changing it
 *      to use gettimeofday () and poll on that instead...
 *********************************************************************************
 */

void delayMicrosecondsHard(unsigned int howLong)
{
    struct timeval tNow, tLong, tEnd;

    gettimeofday(&tNow, NULL);
    tLong.tv_sec = howLong / 1000000;
    tLong.tv_usec = howLong % 1000000;
    timeradd(&tNow, &tLong, &tEnd);

    while (timercmp(&tNow, &tEnd, <)) {
        gettimeofday(&tNow, NULL);
    }
}

void delayMicroseconds(unsigned int howLong)
{
    struct timespec sleeper;
    unsigned int uSecs = howLong % 1000000;
    unsigned int wSecs = howLong / 1000000;

    if (howLong == 0) {
        return;
    } else if (howLong < 100) {
        delayMicrosecondsHard(howLong);
    } else {
        sleeper.tv_sec = wSecs;
        sleeper.tv_nsec = (long) (uSecs * 1000L);
        nanosleep(&sleeper, NULL);
    }
}
