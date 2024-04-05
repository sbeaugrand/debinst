/******************************************************************************!
 * \file wiring.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdint.h>
int wiringSetup();
int digitalInit(uint8_t pin, uint8_t mode);
int digitalQuit(uint8_t pin);
int analogInit();
void analogQuit();

#ifdef WIRING_PI
# include <wiringPi.h>
#else

// arduino-1.0.6/hardware/arduino/cores/arduino/Arduino.h
#define HIGH 0x1
#define LOW 0x0
#define INPUT 0x0
#define OUTPUT 0x1

// wiringPi/wiringPi/wiringPi.h
# define PUD_OFF 0
# define PUD_DOWN 1
# define PUD_UP 2

# define GPIO_ERROR_OPEN 2
# define GPIO_ERROR_READ 3
# define GPIO_ERROR_WRITE 4
# define GPIO_ERROR_CLOSE 5

# define pinMode digitalInit

int digitalRead(uint8_t pin);
void digitalWrite(uint8_t pin, uint8_t val);
int analogRead(uint8_t pin);

#endif
