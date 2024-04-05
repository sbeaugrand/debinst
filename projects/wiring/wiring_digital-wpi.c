/******************************************************************************!
 * \file wiring_digital-wpi.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "wiring.h"

/******************************************************************************!
 * \fn digitalInit
 ******************************************************************************/
int
digitalInit(uint8_t pin, uint8_t mode)
{
    pinMode(pin, mode);
    return 1;
}

/******************************************************************************!
 * \fn digitalQuit
 ******************************************************************************/
int
digitalQuit(uint8_t pin)
{
    pin = pin;
    return 1;
}
