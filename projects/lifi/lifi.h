/*
   LiFi Emitter and Receiver

   The purpose of this demos is to demonstrate data communication using
   a pair of blue LED (one led as emitter one led as receiver).
   Communication can go at up to 600bs (can depend on led quality)

   Emitter hardware :

   I/O 13 ------------- led -------------- GND

   Using a blue led should not require resistor,
   one may be needed for red or green

   Receiver hardware :

            |----1Mohm-----|
   A0 ------|--- +led- ----|------ GND

   A byte is sent as follow :

   Start(0) 8bit data Stop(1), LSB first : 0 b0 b1 b2 b3 b4 b5 b6 b7 1

   Each bit is coded in manchester with time is from left to right
   0 -> 10
   1 -> 01

   A data frame is formatted as follow :

   0xAA : sent a number of time to help the receiver compute a
   signal average for the thresholding of analog values
   0xD5 : synchronization byte to indicate start of a frame,
   breaks the regularity of the 0x55 pattern to be easily
   0x02 : STX start of frame
   N times Effective data excluding command symbols, max length 32 bytes
   0x03 : ETX end of frame
 */

// Change to alter communication speed,
// will lower values will result in faster communication
// the receiver must be tuned to the same value
#define SYMBOL_PERIOD 1000  // Microseconds

// A byte is encoded as a 10-bit value with start and stop bits
#define WORD_LENGTH 10
#define SYNC_SYMBOL 0xD5  // This symbol breaks the premanble of the frame
#define ETX 0x03  // End of frame symbol
#define STX 0x02  // Start or frame symbol
#define DATA_SIZE_MAX 32
