/******************************************************************************!
 * \file mp3client-button.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <wiringPi.h>
#include "mp3client.h"
#include "common.h"

const unsigned int BOUTON_HALT = 8;
const unsigned int BOUTON_RAND = 9;
const unsigned int BOUTON_OK = 2;
const unsigned int BOUTON_GAUCHE = 0;
const unsigned int BOUTON_DROITE = 15;
const unsigned int BOUTON_HAUT = 3;
const unsigned int BOUTON_BAS = 7;

/******************************************************************************!
 * \fn keypadInit
 ******************************************************************************/
void keypadInit()
{
    pinMode(BOUTON_HALT, INPUT);
    pinMode(BOUTON_RAND, INPUT);
    pinMode(BOUTON_OK, INPUT);
    pinMode(BOUTON_GAUCHE, INPUT);
    pinMode(BOUTON_DROITE, INPUT);
    pinMode(BOUTON_HAUT, INPUT);
    pinMode(BOUTON_BAS, INPUT);
    pullUpDnControl(BOUTON_HALT, PUD_UP);
    pullUpDnControl(BOUTON_RAND, PUD_UP);
    pullUpDnControl(BOUTON_OK, PUD_UP);
    pullUpDnControl(BOUTON_GAUCHE, PUD_UP);
    pullUpDnControl(BOUTON_DROITE, PUD_UP);
    pullUpDnControl(BOUTON_HAUT, PUD_UP);
    pullUpDnControl(BOUTON_BAS, PUD_UP);
}

/******************************************************************************!
 * \fn keypadRead
 ******************************************************************************/
void keypadRead()
{
}

/******************************************************************************!
 * \fn keypadInit
 ******************************************************************************/
void keypadQuit()
{
}

/******************************************************************************!
 * \fn leftButton
 ******************************************************************************/
int leftButton()
{
    return digitalRead(BOUTON_GAUCHE) == LOW;
}

/******************************************************************************!
 * \fn downButton
 ******************************************************************************/
int downButton()
{
    return digitalRead(BOUTON_BAS) == LOW;
}

/******************************************************************************!
 * \fn rightButton
 ******************************************************************************/
int rightButton()
{
    return digitalRead(BOUTON_DROITE) == LOW;
}

/******************************************************************************!
 * \fn upButton
 ******************************************************************************/
int upButton()
{
    return digitalRead(BOUTON_HAUT) == LOW;
}

/******************************************************************************!
 * \fn okButton
 ******************************************************************************/
int okButton()
{
    return digitalRead(BOUTON_OK) == LOW;
}

/******************************************************************************!
 * \fn randButton
 ******************************************************************************/
int randButton()
{
    return digitalRead(BOUTON_RAND) == LOW;
}

/******************************************************************************!
 * \fn haltButton
 ******************************************************************************/
int haltButton()
{
    return digitalRead(BOUTON_HALT) == LOW;
}
