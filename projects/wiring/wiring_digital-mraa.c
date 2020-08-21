/******************************************************************************!
 * \file wiring_digital-mraa.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "wiring.h"
#include "mraa/gpio.h"

#ifdef ROCKPIS
# define MRAA_ROCKPIS_PIN_COUNT 52
#else
# error "wiring_digital-mraa not implemented for this board"
#endif
mraa_gpio_context mraa_gpios[MRAA_ROCKPIS_PIN_COUNT] = { NULL };

/******************************************************************************!
 * \fn digitalInit
 ******************************************************************************/
int digitalInit(uint8_t pin, uint8_t mode)
{
    mraa_gpio_context gpio;

    if (mraa_gpios[pin - 1] != NULL) {
        return 1;
    }
    if ((gpio = mraa_gpio_init(pin)) == NULL) {
        return 2;
    }
    if (mraa_gpio_dir(gpio, (mode == INPUT) ?
        MRAA_GPIO_IN : MRAA_GPIO_OUT) != MRAA_SUCCESS) {
        return 3;
    }
    mraa_gpios[pin - 1] = gpio;

    return 0;
}

/******************************************************************************!
 * \fn digitalRead
 ******************************************************************************/
int digitalRead(uint8_t pin)
{
    mraa_gpio_context gpio = mraa_gpios[pin - 1];
    if (gpio == NULL) {
        return -1;
    }

    return mraa_gpio_read(gpio);
}

/******************************************************************************!
 * \fn digitalWrite
 ******************************************************************************/
void digitalWrite(uint8_t pin, uint8_t val)
{
    mraa_gpio_context gpio = mraa_gpios[pin - 1];
    if (gpio == NULL) {
        return;
    }

    if (mraa_gpio_write(gpio, val) != MRAA_SUCCESS) {
        return;
    }
}

/******************************************************************************!
 * \fn digitalQuit
 ******************************************************************************/
int digitalQuit(uint8_t pin)
{
    mraa_gpio_context gpio = mraa_gpios[pin - 1];
    if (gpio == NULL) {
        return -1;
    }

    if (mraa_gpio_close(gpio) != MRAA_SUCCESS) {
        return 1;
    }
    mraa_gpios[pin - 1] = 0;

    return 0;
}
