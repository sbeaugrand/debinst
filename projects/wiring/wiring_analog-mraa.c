/******************************************************************************!
 * \file wiring_analog-mraa.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef ROCKPIS
# error "ADC is implemented for Rockpi"
#endif
#include "wiring.h"
#include "mraa/aio.h"

#define AIO_PORT 0

mraa_aio_context gAio = NULL;

/******************************************************************************!
 * \fn analogInit
 ******************************************************************************/
int analogInit()
{
    if (gAio != NULL) {
        return 0;
    }
    gAio = mraa_aio_init(AIO_PORT);
    if (gAio == NULL) {
        return 0;
    }
    return 1;
}

/******************************************************************************!
 * \fn analogRead
 ******************************************************************************/
int analogRead(uint8_t pin)
{
    if (gAio == NULL) {
        return 0;
    }
    pin = pin;
    return mraa_aio_read(gAio);
}

/******************************************************************************!
 * \fn analogQuit
 ******************************************************************************/
void analogQuit()
{
    if (gAio == NULL) {
        return;
    }
    mraa_aio_close(gAio);
    gAio = NULL;
}
