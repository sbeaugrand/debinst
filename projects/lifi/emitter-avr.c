/******************************************************************************!
 * \file main.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Source: https://github.com/jpiat/arduino
 ******************************************************************************/
#include <util/atomic.h>
#include "tinyX5.h"
#define F_CPU 1000000UL
#include "timer1.h"
#include "lifi.h"

#ifdef MESSAGE
const char* gMessage = MESSAGE;
#endif

unsigned char frame_buffer[DATA_SIZE_MAX + 6];  // Buffer for frame
volatile int8_t frame_index = -1;  // Index in frame
int8_t frame_size = -1;  // Size of the frame to be sent

// State variables of the manchester encoder
unsigned char bit_counter = WORD_LENGTH << 1;
unsigned long int manchester_data = 0xFFFFFFFF;

/******************************************************************************!
 * \fn toManchester
 ******************************************************************************/
void
toManchester(unsigned char data, unsigned long int* data_manchester)
{
    unsigned int i;
    *data_manchester = 0x02;  // STOP symbol
    *data_manchester <<= 2;
    for (i = 0; i < 8; i++) {
        if (data & 0x80) {
            *data_manchester |= 0x02;  // Data LSB first
        } else {
            *data_manchester |= 0x01;
        }
        *data_manchester <<= 2;
        data = data << 1;  // To next bit
    }
    *data_manchester |= 0x01;  // START symbol
}

/******************************************************************************!
 * \fn TIMER1_COMPA_vect
 ******************************************************************************/
ISR(TIMER1_COMPA_vect)
{
    if (manchester_data & 0x01) {
        digitalWrite(A_PINB0, 1);
    } else {
        digitalWrite(A_PINB0, 0);
    }
    bit_counter--;
    manchester_data >>= 1;
    if (bit_counter == 0) {
        if (frame_index >= 0) {
            if (frame_index < frame_size) {
                toManchester(frame_buffer[frame_index], &manchester_data);
                frame_index++;
            } else {
                frame_index = -1;
                frame_size = -1;
            }
        }
        bit_counter = WORD_LENGTH << 1;
    }
}

/******************************************************************************!
 * \fn write
 ******************************************************************************/
int
write(const char* data, int data_size)
{
    if (frame_index >= 0) {
        return -1;
    }
    if (data_size > DATA_SIZE_MAX) {
        return -1;
    }
    memcpy(&(frame_buffer[5]), data, data_size);
    frame_buffer[5 + data_size] = ETX;
    cli();
    frame_index = 0;
    frame_size = data_size + 6;
    sei();
    return 0;
}

/******************************************************************************!
 * \fn setup
 ******************************************************************************/
void
setup()
{
    pinMode(A_PINB0, OUTPUT);

    // Init frame
    memset(frame_buffer, 0xAA, 3);
    frame_buffer[3] = SYNC_SYMBOL;
    frame_buffer[4] = STX;

    // Timer
    timer1SetPeriod(SYMBOL_PERIOD);

#   ifdef MESSAGE
    int len = strlen(gMessage);
    int pos = 0;
    while (len > 0) {
        if (write(gMessage + pos,
                  (len < DATA_SIZE_MAX) ? len : DATA_SIZE_MAX) < 0) {
        } else {
            len -= DATA_SIZE_MAX;
            pos += DATA_SIZE_MAX;
        }
    }
#   endif
}

/******************************************************************************!
 * \fn loop
 ******************************************************************************/
void
loop()
{
#   ifndef MESSAGE
    static char* msg = "Hello World";

    if (write(msg, 11) < 0) {
    }
#   endif
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main()
{
    setup();
    for (;;) {
        loop();
    }
}
