/******************************************************************************!
 * \file mp3client-rpi.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <wiringPi.h>
#include <lcd.h>
#include "mp3client.h"
#include "common.h"

const unsigned int LCD_ROWS = 2;
const unsigned int LCD_RS = 10;
const unsigned int LCD_E = 6;
const unsigned int LCD_D4 = 5;
const unsigned int LCD_D5 = 4;
const unsigned int LCD_D6 = 1;
const unsigned int LCD_D7 = 16;

const unsigned int BOUTON_HALT = 8;
const unsigned int BOUTON_RAND = 9;
const unsigned int BOUTON_OK = 2;
const unsigned int BOUTON_GAUCHE = 0;
const unsigned int BOUTON_DROITE = 15;
const unsigned int BOUTON_HAUT = 3;
const unsigned int BOUTON_BAS = 7;

/******************************************************************************!
 * \fn updateDisplay
 ******************************************************************************/
void updateDisplay(const char* line1, const char* line2)
{
    static int fd = -1;
    static char buff[LCD_COLS + 1] = {
        0
    };

    if (fd == -1) {
        fd = lcdInit(LCD_ROWS, LCD_COLS, 4, LCD_RS, LCD_E,
                     LCD_D4, LCD_D5, LCD_D6, LCD_D7, 0, 0, 0, 0);
        if (fd == -1) {
            return;
        }
        buff[LCD_COLS] = '\0';
    }
    lcdClear(fd);
    strncpy(buff, line1, LCD_COLS);
    lcdPosition(fd, 0, 0);
    lcdPuts(fd, buff);
    strncpy(buff, line2, LCD_COLS);
    lcdPosition(fd, 0, 1);
    lcdPuts(fd, buff);
    nanoSleep(500000000);
}

/******************************************************************************!
 * \fn initDisplay
 ******************************************************************************/
void initDisplay()
{
    if (wiringPiSetup() == -1) {
        exit(EXIT_FAILURE);
    }
    updateDisplay("", "");

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
 * \fn readButton
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
