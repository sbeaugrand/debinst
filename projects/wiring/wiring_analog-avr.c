/******************************************************************************!
 * \file wiring_analog-avr.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <avr/io.h>

/******************************************************************************!
 * \fn analogInit
 ******************************************************************************/
int
analogInit()
{
    ADMUX = (1 << REFS2) | (1 << REFS1) |  // Vref = 2.56 V
        (1 << MUX3) | (1 << MUX2) | (1 << MUX0);  // GND
    ADCSRA = (1 << ADEN);
    if (F_CPU / 200000 > 64) {
        ADCSRA |= 7;
    } else if (F_CPU / 200000 > 32) {
        ADCSRA |= 6;
    } else if (F_CPU / 200000 > 16) {
        ADCSRA |= 5;
    } else if (F_CPU / 200000 > 8) {
        ADCSRA |= 4;
    } else if (F_CPU / 200000 > 4) {
        ADCSRA |= 3;
    } else if (F_CPU / 200000 > 2) {
        ADCSRA |= 2;
    } else if (F_CPU / 200000 > 1) {
        ADCSRA |= 1;
    }
    return 1;
}

/******************************************************************************!
 * \fn analogRead
 * \note pin = next pin
 ******************************************************************************/
int
analogRead(uint8_t pin)
{
    if (ADCSRA & (1 << ADSC)) {
        return -1;
    }

    switch (pin) {
    case ADC0D: ADMUX = (ADMUX & 0xF0) | 0; break;  // PINB5 (pin 1)
    case ADC1D: ADMUX = (ADMUX & 0xF0) | 1; break;  // PINB2 (pin 7)
    case ADC2D: ADMUX = (ADMUX & 0xF0) | 2; break;  // PINB4 (pin 3)
    case ADC3D: ADMUX = (ADMUX & 0xF0) | 3; break;  // PINB3 (pin 2)
    }
    ADCSRA |= (1 << ADSC);

    return ADC;
}

/******************************************************************************!
 * \fn analogQuit
 ******************************************************************************/
void
analogQuit()
{
    ADCSRA &= ~(1 << ADEN);
}
