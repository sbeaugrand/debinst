/******************************************************************************!
 * \file wiring_analog-g25.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdint.h>
#include "wiring.h"

static int analogFD = -1;

/******************************************************************************!
 * \fn analogInit
 ******************************************************************************/
int analogInit()
{
    analogFD = -1;
    return 1;
}

/******************************************************************************!
 * \fn analogRead
 ******************************************************************************/
int analogRead(uint8_t pin)
{
    static char buffer[67];
    static uint8_t lastPin = 255;

    if (pin != lastPin) {
        analogQuit();
        if (snprintf(buffer, 67,
                     "/sys/bus/platform/devices/f804c000.adc/"
                     "iio:device0/in_voltage%u_raw", pin) >= 67) {
            return -1;
        }
        if ((analogFD = open(buffer, O_RDONLY)) < 0) {
            return -1;
        }
        lastPin = pin;
    } else {
        lseek(analogFD, 0, SEEK_SET);
    }

    if (read(analogFD, buffer, 5) < 0) {
        return -1;
    }
    return atoi(buffer);
}

/******************************************************************************!
 * \fn analogQuit
 ******************************************************************************/
void analogQuit()
{
    if (analogFD >= 0) {
        close(analogFD);
        analogFD = -1;
    }
}
