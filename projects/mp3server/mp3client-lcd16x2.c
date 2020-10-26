/******************************************************************************!
 * \file mp3client-lcd16x2.c
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

/******************************************************************************!
 * \fn displayInit
 ******************************************************************************/
void displayInit()
{
    if (wiringPiSetup() == -1) {
        exit(EXIT_FAILURE);
    }
    displayWrite("", "");
}

/******************************************************************************!
 * \fn displayWrite
 ******************************************************************************/
void displayWrite(const char* line1, const char* line2)
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
 * \fn displayScreenSaver
 ******************************************************************************/
void displayScreenSaver()
{
}

/******************************************************************************!
 * \fn displayQuit
 ******************************************************************************/
void displayQuit()
{
}
