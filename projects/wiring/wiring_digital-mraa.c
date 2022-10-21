/******************************************************************************!
 * \file wiring_digital-mraa.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "wiring.h"
#include "mraa/gpio.h"

// PIN_COUNT
// Rockpi S : 52
// NanoPi Neo : 24
// Orange Pi Zero : 26
#define MRAA_MAX_PIN_COUNT 52
mraa_gpio_context mraa_gpios[MRAA_MAX_PIN_COUNT] = { NULL };

/******************************************************************************!
 * \fn digitalInit
 ******************************************************************************/
int digitalInit(uint8_t pin, uint8_t mode)
{
    mraa_gpio_context gpio = mraa_gpios[pin - 1];

    if (gpio == NULL) {
        if ((gpio = mraa_gpio_init(pin)) == NULL) {
            return 1;
        } else {
            mraa_gpios[pin - 1] = gpio;
        }
    }
    if (mraa_gpio_dir(gpio, (mode == INPUT) ?
        MRAA_GPIO_IN : MRAA_GPIO_OUT) != MRAA_SUCCESS) {
        digitalQuit(pin);
        return 2;
    }
    if (mode == INPUT) {
        //FIXME: workaround for NanoPi Neo and Orange Pi Zero
        /* To reproduce :
         * sudo mraa-gpio monitor 11
         * Monitoring level changes to pin 11. Press RETURN to exit.
         * Pin 11 = 1
         *
         * sudo mraa-gpio get 11
         * Pin 11 = 0
         */
        mraa_gpio_edge_mode(gpio, MRAA_GPIO_EDGE_BOTH);
    }

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
    mraa_gpios[pin - 1] = NULL;

    return 0;
}
