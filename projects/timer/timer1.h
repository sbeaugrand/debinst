/******************************************************************************!
 * \file timer1.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef AVR_TIMER1
#define AVR_TIMER1

#if defined(__arm__) || defined(__aarch64__)
# include <sys/time.h>
# include <signal.h>
# include <errno.h>

void
timer1SetPeriod(unsigned long microseconds)
{
    struct itimerval it = { { 0, microseconds }, { 0, microseconds } };
    if (setitimer(ITIMER_REAL, &it, 0) != 0) {
        perror("setitimer");
    }
}

void (* gIsr)() = NULL;

static void
sigalarm_handler(int s) {
    s = s;
    if (gIsr == NULL) {
        perror("gIsr == NULL");
        return;
    }
    (*gIsr)();
}

void
timer1AttachInterrupt(void (* isr)())
{
    struct sigaction sa;

    if (gIsr != NULL) {
        perror("gIsr != NULL");
    }
    gIsr = isr;

    sa.sa_handler = sigalarm_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(SIGALRM, &sa, NULL) != 0) {
        perror("sigaction");
    }
}

#else

#if defined (__AVR_ATtiny2313__)
# define TIMER1_RESOLUTION 65536UL
#else  // tinyX5
# define TIMER1_RESOLUTION 256UL
#endif

/******************************************************************************!
 * \fn timer1SetPeriod
 ******************************************************************************/
void
timer1SetPeriod(unsigned long microseconds)
{
    uint8_t prescaler;
    uint32_t ocr;

#   if defined (__AVR_ATtiny2313__)
    for (prescaler = 1; prescaler < 6; ++prescaler) {
#   else  // tinyX5
    for (prescaler = 1; prescaler < 16; ++prescaler) {
#   endif
#       if defined (__AVR_ATtiny2313__)
        // Clock div: 1 8 64 256 1024
        // Shift: 0 3 6 8 10
        ocr = prescaler << 1;
        if (ocr == 2) {
            ocr = 0;
        } else if (ocr == 4) {
            ocr = 3;
        }
        ocr = ((F_CPU / 1000000 * microseconds) >> ocr) - 1;
#       else  // tinyX5
        ocr = ((F_CPU / 1000000 * microseconds) >> (prescaler - 1)) - 1;
#       endif
        if (ocr <= TIMER1_RESOLUTION) {
            break;
        }
    }
    if (ocr >= TIMER1_RESOLUTION) {
        ocr = TIMER1_RESOLUTION - 1;
    }

    OCR1A = ocr;
#   if defined (__AVR_ATtiny2313__)
    TCCR1A = 0;
    TCCR1B = (TCCR1B & ~((1 << CS12) | (1 << CS11) | (1 << CS10))) | prescaler;
#   else  // tinyX5
    TCCR1 = (TCCR1 & ~((1 << CS13) | (1 << CS12) |
                       (1 << CS11) | (1 << CS10))) | prescaler;
#   endif

    TCNT1 = 0;
    TIMSK |= (1 << OCIE1A);
}

#endif

#endif
