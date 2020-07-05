/******************************************************************************!
 * \file blink.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "arm/wiringPi/wiringPi.h"

int main(int argc, char* argv[])
{
    int pin;
    int i;

    if (argc != 2) {
        printf("Usage: blink <pin>\n");
        return EXIT_FAILURE;
    }
    pin = atoi(argv[1]);

    if (pinMode(pin, OUTPUT)) {
        printf("error: pinMode(%d, OUTPUT) failed\n", pin);
        return EXIT_FAILURE;
    }
    for (i = 0; i < 8; ++i) {
        digitalWrite(pin, HIGH);
        delayMicroseconds(1000000);
        digitalWrite(pin, LOW);
        delayMicroseconds(1000000);
    }
    digitalQuit(pin);

    return EXIT_FAILURE;
}
