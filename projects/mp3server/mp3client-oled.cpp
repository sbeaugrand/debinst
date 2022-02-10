/******************************************************************************!
 * \file mp3client-rps.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "ssd1306.hpp"

#define DEVICE_ADDRESS 0x3C

const unsigned int LCD_ROWS = upm::SSD1306_LCDHEIGHT >> 3;

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

    try {
        gOled = new upm::SSD1306(0, DEVICE_ADDRESS);
    } catch (...) {
        gOled = new upm::SSD1306(1, DEVICE_ADDRESS);
    }
    if (gOled == nullptr) {
        return;
    }
    gOled->clear();
    // SH1106 workarround
    for (unsigned int i = 0; i < LCD_ROWS; ++i) {
        gOled->setCursor(i, LCD_COLS - 2);
        gOled->write("  ");
    }
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
    gOled->setCursor((LCD_ROWS >> 1) - 1, 0);
    gOled->write(gDisplayBuff);
    strncpy(gDisplayBuff, line2, LCD_COLS);
    gOled->setCursor((LCD_ROWS >> 1) + 1, 0);
    gOled->write(gDisplayBuff);
    nanoSleep(500000000);
}

/******************************************************************************!
 * \fn displayScreenSaver
 ******************************************************************************/
int displayScreenSaver()
{
    static char* root = NULL;

    const unsigned int width = 5;
    const unsigned int height = 5;
    time_t tOfTheDay;
    struct tm* tmOfTheDay;
    char line[LINE_SIZE];
    FILE* fp;
    static int r = -1;
    int x;
    int y;

    if (root == NULL) {
        root = getenv("MP3DIR");
        if (root == NULL) {
            root = const_cast<char*>("/mnt/mp3");
        }
    }
    strcpy(line, root);
    strcat(line, "/mp3");

    if (gOled == nullptr) {
        return 1;
    }
    gOled->clear();

    tOfTheDay = time(NULL);
    tmOfTheDay = localtime(&tOfTheDay);
    if (access(line, R_OK) != 0) {
        strftime(line, sizeof(line), "%dX%m %H:%M", tmOfTheDay);
    } else {
        strftime(line, sizeof(line), "%d-%m %H:%M", tmOfTheDay);
    }

    if (r == -1) {
        srand(tOfTheDay);
    }
    r = rand() % ((LCD_COLS - (width - 1)) * (LCD_ROWS - (height - 1)));
    x = r % (LCD_COLS - (width - 1));
    y = r / (LCD_COLS - (width - 1));

    line[width] = '\0';
    if (gOled->setCursor(y, x) != mraa::SUCCESS) {
        return 2;
    }
    gOled->write(line);
    gOled->setCursor(y + height - 1, x);
    gOled->write(line + width + 1);

    fp = fopen("/run/shutter.at", "r");
    if (fp != NULL) {
        if (fgets(line, sizeof(line), fp) != NULL) {
            gOled->setCursor(y + 2, x);
            gOled->write(line);
        }
        fclose(fp);
    }

    return 0;
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
