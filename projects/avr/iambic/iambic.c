/******************************************************************************!
 * \file iambic.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <avr/io.h>

#define F_CPU 8000000UL
#include <util/delay.h>

// Broches
#define PIN_TONE _BV(PB0)
#define PIN_KEY _BV(PB1)
#define PIN_DOT _BV(PB3)
#define PIN_DASH _BV(PB4)

// Etat du manipulateur
#define STATE_COUNT 159  // 256 - 97
enum {
    STATE_IDLE,
    STATE_DOT,
    STATE_DASH,
    STATE_WAIT_DOT,
    STATE_WAIT_DASH
};

// Etat des palettes
enum {
    PADDLE_NOT_PRESSED,
    PADDLE_PRESSED,
    PADDLE_MAINTENED,
    PADDLE_OPERATED
};

// Tampon
#define BUFF_SIZE 8  // 2^n

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
    // Globales
    uint8_t gBuff[BUFF_SIZE] = {
        0
    };
    uint8_t gRPos = 0;
    uint8_t gWPos = 0;
    uint8_t gState = STATE_IDLE;

    // Pour timer 1
    uint8_t nextState = STATE_IDLE;
    uint8_t dashCount = 0;
    uint8_t stateCount = STATE_COUNT;

    // Locales
    uint8_t dotState = PADDLE_NOT_PRESSED;
    uint8_t dashState = PADDLE_NOT_PRESSED;

    // Ports
    DDRB = PIN_KEY;  // sorties=1
    PORTB = PIN_DOT | PIN_DASH;  // entrees

    // Timer 0
    GTCCR = 0x00;
    OCR0A = 89;  // 700 Hz
    TCCR0A = 0x42;
    TCCR0B = 0x03;

    // Timer 1
    TCNT1 = STATE_COUNT;
    TCCR1 = 0x0e;

    // ADC
    ADMUX = 0x21;
    ADCSRA = 0xf6;
    ADCSRB = 0x00;
    DIDR0 = 1 << ADC1D;

    for (;;) {
        _delay_ms(10);  // 10 = 100 Hz

        if (TIFR & (1 << TOV1)) {
            TIFR |= (1 << TOV1);
            TCNT1 = stateCount;

            gState = nextState;
            if (gState == STATE_IDLE && gBuff[gRPos] != 0) {
                gState = gBuff[gRPos];
                gBuff[gRPos] = 0;
                ++gRPos;
                if (gRPos & BUFF_SIZE) {
                    gRPos = 0;
                }
            }

            switch (gState)
            {
            case STATE_IDLE:
                // Vitesse
                if ((ADCSRA & (1 << ADIF)) == (1 << ADIF)) {
                    stateCount = 256 - ADCH;
                    ADCSRA |= (1 << ADIF);
                }
                break;
            case STATE_DOT:  // Envoie point
                DDRB |= PIN_TONE;
                PORTB |= PIN_KEY;
                nextState = STATE_WAIT_DOT;
                break;
            case STATE_DASH:  // Envoie trait
                DDRB |= PIN_TONE;
                PORTB |= PIN_KEY;
                ++dashCount;
                if (dashCount >= 3) {
                    dashCount = 0;
                    nextState = STATE_WAIT_DASH;
                } else {
                    nextState = STATE_DASH;
                }
                break;
            case STATE_WAIT_DOT:  // Fin du point
                DDRB &= ~PIN_TONE;
                PORTB &= ~PIN_KEY;
                nextState = STATE_IDLE;
                break;
            case STATE_WAIT_DASH:  // Fin du trait
                DDRB &= ~PIN_TONE;
                PORTB &= ~PIN_KEY;
                nextState = STATE_IDLE;
                break;
            }
        }

        if ((PINB & PIN_DOT) == 0) {
            if (dotState == PADDLE_NOT_PRESSED) {
                dotState = PADDLE_PRESSED;
            } else if (dotState == PADDLE_PRESSED) {
                dotState = PADDLE_MAINTENED;
            }
        } else {
            dotState = PADDLE_NOT_PRESSED;
        }
        if ((PINB & PIN_DASH) == 0) {
            if (dashState == PADDLE_NOT_PRESSED) {
                dashState = PADDLE_PRESSED;
            } else if (dashState == PADDLE_PRESSED) {
                dashState = PADDLE_MAINTENED;
            }
        } else {
            dashState = PADDLE_NOT_PRESSED;
        }
        if (gState == STATE_WAIT_DASH) {
            if (dotState == PADDLE_MAINTENED) {
                gBuff[gWPos] = STATE_DOT;
                ++gWPos;
                if (gWPos & BUFF_SIZE) {
                    gWPos = 0;
                }
                dotState = PADDLE_OPERATED;
                continue;
            }
            if (dashState == PADDLE_MAINTENED) {
                gBuff[gWPos] = STATE_DASH;
                ++gWPos;
                if (gWPos & BUFF_SIZE) {
                    gWPos = 0;
                }
                dashState = PADDLE_OPERATED;
                continue;
            }
        } else if (gState == STATE_WAIT_DOT || gState == STATE_IDLE) {
            if (dashState == PADDLE_MAINTENED) {
                gBuff[gWPos] = STATE_DASH;
                ++gWPos;
                if (gWPos & BUFF_SIZE) {
                    gWPos = 0;
                }
                dashState = PADDLE_OPERATED;
                continue;
            }
            if (dotState == PADDLE_MAINTENED) {
                gBuff[gWPos] = STATE_DOT;
                ++gWPos;
                if (gWPos & BUFF_SIZE) {
                    gWPos = 0;
                }
                dotState = PADDLE_OPERATED;
                continue;
            }
        }
        if (gState == STATE_DOT && dotState == PADDLE_OPERATED) {
            dotState = PADDLE_NOT_PRESSED;
        }
        if (gState == STATE_DASH && dashState == PADDLE_OPERATED) {
            dashState = PADDLE_NOT_PRESSED;
        }
    }
}
