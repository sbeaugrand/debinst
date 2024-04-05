/******************************************************************************!
 * \file test-timer45.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
unsigned long F_CPU = 4000000UL;

#define CS13 3
#define CS12 2
#define CS11 1
#define CS10 0
#define OCIE0A 4
#define OCIE1A 6
uint8_t OCR0A;
uint8_t TCCR0A;
uint8_t TCCR0B;
uint8_t TCNT0;
uint8_t TCNT1;
uint8_t TIMSK;
uint8_t OCR1A;
uint8_t TCCR1;

#define __AVR_ATtiny45__
#include "timer0.h"
#include "timer1.h"

int
main(int argc, char** argv)
{
    unsigned long period;

    if (argc != 4) {
        return EXIT_FAILURE;
    }

    F_CPU = atol(argv[1]);
    period = atol(argv[3]);

    if (atoi(argv[2]) == 0) {
        timer0SetPeriod(period);
        fprintf(stdout, "%s %s %s %s: TCCR0B = %u\n",
                argv[0], argv[1], argv[2], argv[3], TCCR0B);
        fprintf(stdout, "%s %s %s %s: OCR0A = %u\n",
                argv[0], argv[1], argv[2], argv[3], OCR0A);
    } else {
        timer1SetPeriod(period);
        fprintf(stdout, "%s %s %s %s: TCCR1 = %u\n",
                argv[0], argv[1], argv[2], argv[3], TCCR1);
        fprintf(stdout, "%s %s %s %s: OCR1A = %u\n",
                argv[0], argv[1], argv[2], argv[3], OCR1A);
    }

    return EXIT_SUCCESS;
}
