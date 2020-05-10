#include <stdint.h>

#define PROGMEM

#define pgm_read_byte_near(a) (Sinewave[a - Sinewave])
