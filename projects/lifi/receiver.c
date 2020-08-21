/******************************************************************************!
 * \file receiver.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Source: https://github.com/jpiat/arduino
 ******************************************************************************/
#include <stdio.h>
#include <stdint.h>
#include "lifi.h"
#include "wiring.h"
#include "timer1.h"
#include "debug.h"

#define PIN_LED 11

enum receiver_state
{
    IDLE,  // Waiting for sync
    SYNC,  // Synced, waiting for STX
    START,  // STX received
    DATA  // Receiving DATA
};
enum receiver_state frame_state = IDLE;

// This defines receiver properties
#define SAMPLE_PER_SYMBOL 4

// Global variables for frame decoding
char frame_buffer[38];
int frame_index = -1;
int frame_size = -1;

// State variables of the thresholder
unsigned int signal_mean = 0;
unsigned long acc_sum = 0;  // Used to compute the signal mean value
unsigned int acc_counter = 0;

// Manechester decoder state variable
long shift_reg = 0;

/******************************************************************************!
 * \fn is_a_word
 ******************************************************************************/
#define START_SYMBOL 0x02
#define STOP_SYMBOL 0x01
#define START_STOP_MASK ((STOP_SYMBOL << 20) | \
                         (START_SYMBOL << 18) | \
                         STOP_SYMBOL)  // STOP/START/16bits/STOP
#define SYNC_SYMBOL_MANCHESTER (0x6665)
inline int is_a_word(long* manchester_word,
                     int time_from_last_sync,
                     unsigned int* detected_word)
{
    if (time_from_last_sync >= 20 || frame_state == IDLE) {
        // We received enough bits to test the sync
        if (((*manchester_word) & START_STOP_MASK) == (START_STOP_MASK)) {
            // Testing first position
            (*detected_word) = ((*manchester_word) >> 2) & 0xFFFF;
            if (frame_state == IDLE) {
                if ((*detected_word) == SYNC_SYMBOL_MANCHESTER) {
                    return 2;
                }
            }
            return 1;
            // Byte with correct framing
        } else if (frame_state != IDLE && time_from_last_sync == 20) {
            (*detected_word) = ((*manchester_word) >> 2) & 0xFFFF;
            return 1;
        }
    }
    return 0;
}

/******************************************************************************!
 * \fn insert_edge
 ******************************************************************************/
inline int insert_edge(long* manchester_word,
                       int8_t edge,
                       int edge_period,
                       int* time_from_last_sync,
                       unsigned int* detected_word)
{
    int new_word = 0;
    int is_a_word_value = 0;
    int sync_word_detect = 0;
    if (((*manchester_word) & 0x01) != edge) {
        // Make sure we don't have same edge
        if (edge_period > (SAMPLE_PER_SYMBOL + 1)) {
            unsigned char last_bit = (*manchester_word) & 0x01;
            // Signal was steady for longer than a single symbol
            (*manchester_word) = ((*manchester_word) << 1) | last_bit;
            (*time_from_last_sync) += 1;
            is_a_word_value = is_a_word(manchester_word,
                                        (*time_from_last_sync),
                                        detected_word);
            if (is_a_word_value > 0) {  // Found start stop framing
                new_word = 1;
                (*time_from_last_sync) = 0;
                if (is_a_word_value > 1) {
                    // We detected framing and sync word in manchester format
                    sync_word_detect = 1;
                }
            }
        }
        // Storing edge value in word
        if (edge < 0) {
            // Signal goes down
            (*manchester_word) = ((*manchester_word) << 1) | 0x00;
        } else {
            // Signal goes up
            (*manchester_word) = ((*manchester_word) << 1) | 0x01;
        }
        (*time_from_last_sync) += 1;
        is_a_word_value = is_a_word(manchester_word,
                                    (*time_from_last_sync),
                                    detected_word);
        // If sync word was detected at previous position,
        // don't take word detection into account
        if (sync_word_detect == 0 && is_a_word_value > 0) {
            new_word = 1;
            (*time_from_last_sync) = 0;
        }
    } else {
        new_word = -1;
    }
    return new_word;
}

/******************************************************************************!
 * \fn sample_signal_edge
 ******************************************************************************/
#define EDGE_THRESHOLD 0
int oldValue = 0;
int steady_count = 0;
int dist_last_sync = 0;
unsigned int detected_word = 0;
int gNewWord = 0;
char old_edge_val = 0;

void sample_signal_edge()
{
    char edge_val;
    int sensorValue = digitalRead(PIN_LED);
    fprintf(stderr, "%d", sensorValue);
    if ((sensorValue - oldValue) > EDGE_THRESHOLD) {
        edge_val = -1;
    } else if ((oldValue - sensorValue) > EDGE_THRESHOLD) {
        edge_val = 1;
    } else {
        edge_val = 0;
    }
    oldValue = sensorValue;
    if (edge_val == 0 || edge_val == old_edge_val ||
        (edge_val != old_edge_val && steady_count < 2)) {
        if (steady_count < (4 * SAMPLE_PER_SYMBOL)) {
            steady_count++;
        }
    } else {
        gNewWord =
            insert_edge(&shift_reg,
                        edge_val,
                        steady_count,
                        &(dist_last_sync),
                        &detected_word);
        if (dist_last_sync > (8 * SAMPLE_PER_SYMBOL)) {
            // Limit dist_last_sync to avoid overflow problems
            dist_last_sync = 32;
        }
        // if (gNewWord >= 0) {
        steady_count = 0;
        // }
    }
    old_edge_val = edge_val;
}

/******************************************************************************!
 * \fn add_byte_to_frame
 ******************************************************************************/
int add_byte_to_frame(char* frame_buffer,
                      int* frame_index,
                      int* frame_size,
                      enum receiver_state* frame_state,
                      unsigned char data) {
    if (data == SYNC_SYMBOL  /*&& (*frame_index) < 0*/) {
        DEBUG("SYNC");
        (*frame_index) = 0;
        (*frame_size) = 0;
        (*frame_state) = SYNC;
        return 0;
    }
    if ((*frame_state) != IDLE) {  // We are synced
        frame_buffer[*frame_index] = data;
        (*frame_index)++;
        if (data == STX) {
            DEBUG("START");
            (*frame_state) = START;
            return 0;
        } else if (data == ETX) {
            DEBUG("END");
            (*frame_size) = (*frame_index);
            (*frame_index) = -1;
            (*frame_state) = IDLE;
            return 1;
        } else if ((*frame_index) >= 38) {
            // Frame is larger than max size of frame
            (*frame_index) = -1;
            (*frame_size) = -1;
            (*frame_state) = IDLE;
            return -1;
        } else {
            (*frame_state) = DATA;
        }
        return 0;
    }
    return -1;
}

/******************************************************************************!
 * \fn setup
 ******************************************************************************/
void setup()
{
    int ret;
    if ((ret = digitalInit(PIN_LED, INPUT)) != 0) {
        ERROR("digitalInit = %d", ret);
    }
    timer1SetPeriod(SYMBOL_PERIOD / SAMPLE_PER_SYMBOL);
    timer1AttachInterrupt(sample_signal_edge);
}

/******************************************************************************!
 * \fn loop
 ******************************************************************************/
void loop()
{
    int i;
    unsigned char received_data;
    int byte_added = 0;
    if (gNewWord == 1) {
        received_data = 0;
        for (i = 0; i < 16; i = i + 2) {  // Decoding Manchester
            received_data = received_data << 1;
            if (((detected_word >> i) & 0x03) == 0x01) {
                received_data |= 0x01;
            } else {
                received_data &= ~0x01;
            }
        }
        received_data = received_data & 0xFF;
        DEBUG("%d, %c", received_data & 0xFF, received_data);
        gNewWord = 0;
        if ((byte_added =
                 add_byte_to_frame(frame_buffer, &frame_index, &frame_size,
                                   &frame_state,
                                   received_data)) > 0) {
            frame_buffer[frame_size - 1] = '\0';
            DEBUG("%s", &frame_buffer[1]);
        }
        if (frame_state != IDLE) {
            DEBUG("%x", received_data);
        }
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
    setup();
    for (;;) {
        loop();
    }
}
