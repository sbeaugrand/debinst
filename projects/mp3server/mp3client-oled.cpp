/******************************************************************************!
 * \file mp3client-rps.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "ssd1306.hpp"

#define DEVICE_ADDRESS 0x3C
#define BUS_NUMBER 0x1

const unsigned int LCD_ROWS = 2;

upm::SSD1306* gOled = nullptr;

extern "C" {
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "mp3client.h"
#include "common.h"

char gDisplayBuff[LCD_COLS + 1] = {
    0
};

/******************************************************************************!
 * \fn displayInit
 ******************************************************************************/
void displayInit()
{
    if (gOled != nullptr) {
        return;
    }
    gOled = new upm::SSD1306(BUS_NUMBER, DEVICE_ADDRESS);
    if (gOled == nullptr) {
        return;
    }
    gOled->clear();
    gOled->dim(true);
    gDisplayBuff[LCD_COLS] = '\0';
}

/******************************************************************************!
 * \fn displayWrite
 ******************************************************************************/
void displayWrite(const char* line1, const char* line2)
{
    if (gOled == nullptr) {
        return;
    }
    gOled->clear();

    strncpy(gDisplayBuff, line1, LCD_COLS);
    gOled->setCursor(3, 0);
    gOled->write(gDisplayBuff);
    strncpy(gDisplayBuff, line2, LCD_COLS);
    gOled->setCursor(5, 0);
    gOled->write(gDisplayBuff);
    nanoSleep(500000000);
}

/******************************************************************************!
 * \fn displayScreenSaver
 ******************************************************************************/
void displayScreenSaver()
{
    time_t tOfTheDay;
    struct tm* tmOfTheDay;
    char dateOfTheDay[12];
    static int r = -1;
    int x;
    int y;

    if (gOled == nullptr) {
        return;
    }
    gOled->clear();

    tOfTheDay = time(NULL);
    tmOfTheDay = localtime(&tOfTheDay);
    strftime(dateOfTheDay, sizeof(dateOfTheDay), "%d-%m %H:%M", tmOfTheDay);

    if (r == -1) {
        srand(tOfTheDay);
    }
    r = rand() % 72;
    x = r % 12;
    y = r / 12;

    dateOfTheDay[5] = '\0';
    gOled->setCursor(y, x);
    gOled->write(dateOfTheDay);
    gOled->setCursor(y + 2, x);
    gOled->write(dateOfTheDay + 6);
}

/******************************************************************************!
 * \fn displayQuit
 ******************************************************************************/
void displayQuit()
{
    if (gOled == nullptr) {
        return;
    }
    gOled->clear();
    delete gOled;
    gOled = nullptr;
}

}
