/******************************************************************************!
 * \file timer0.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef AVR_TIMER0
#define AVR_TIMER0

#define TIMER0_RESOLUTION 256UL

/******************************************************************************!
 * \fn timer0SetPeriod
 ******************************************************************************/
void
timer0SetPeriod(unsigned long microseconds)
{
    uint8_t prescaler;
    uint16_t ocr;

    for (prescaler = 1;
         prescaler < 6;
         ++prescaler) {
        // Clock div: 1 8 64 256 1024
        // Shift: 0 3 6 8 10
        ocr = prescaler << 1;
        if (ocr == 2) {
            ocr = 0;
        } else if (ocr == 4) {
            ocr = 3;
        }
        ocr = ((F_CPU / 1000000 * microseconds) >> ocr) - 1;
        if (ocr <= TIMER0_RESOLUTION) {
            break;
        }
    }
    if (ocr >= TIMER0_RESOLUTION) {
        ocr = TIMER0_RESOLUTION - 1;
    }

    OCR0A = ocr;
    TCCR0A = 0;
    TCCR0B = (TCCR0B & ~((1 << CS12) | (1 << CS11) | (1 << CS10))) | prescaler;

    TCNT0 = 0;
    TIMSK |= (1 << OCIE0A);
}

#endif
