/******************************************************************************!
 * \file blink.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "wiringPi.h"

int
main(int argc, char* argv[])
{
    int led;
    int button;
    int i;

    if (argc < 2) {
        printf("Usage: blink <pin>\n");
        return EXIT_FAILURE;
    }
    led = atoi(argv[1]);

    if (pinMode(led, OUTPUT)) {
        printf("error: pinMode(%d, OUTPUT) failed\n", led);
        return EXIT_FAILURE;
    }
    for (i = 0; i < 5; ++i) {
        digitalWrite(led, HIGH);
        delay(1000);
        digitalWrite(led, LOW);
        delay(1000);
    }

    if (argc != 3) {
        digitalQuit(led);
        return EXIT_SUCCESS;
    }

    button = atoi(argv[2]);
    if (pinMode(button, INPUT)) {
        printf("error: pinMode(%d, INPUT) failed\n", button);
        return EXIT_FAILURE;
    }

    for (i = 0; i < 100; ++i) {
        if (digitalRead(button) == LOW) {
            digitalQuit(button);
            for (i = 0; i < 5; ++i) {
                digitalWrite(led, HIGH);
                delay(500);
                digitalWrite(led, LOW);
                delay(500);
            }
            digitalQuit(led);
            return EXIT_SUCCESS;
        }
        delay(100);
    }

    digitalQuit(led);
    digitalQuit(button);
    return EXIT_SUCCESS;
}
