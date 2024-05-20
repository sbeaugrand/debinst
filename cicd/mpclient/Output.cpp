/******************************************************************************!
 * \file Output.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <filesystem>
#include <fstream>
#include "Output.h"
#include "common.h"

#define DEVICE_ADDRESS 0x3C

const unsigned int LCD_COLS = 16;
#if defined(__arm__) || defined(__aarch64__)
const unsigned int LCD_ROWS = upm::SSD1306_LCDHEIGHT >> 3;
#else
const unsigned int LCD_ROWS = 8;
#endif

char gOutputBuff[LCD_COLS + 1] = {
    0
};

/******************************************************************************!
 * \fn Output
 ******************************************************************************/
Output::Output(const std::string& path)
    : mPath(path)
{
    this->open();
}

/******************************************************************************!
 * \fn ~Output
 ******************************************************************************/
Output::~Output()
{
    this->close();
}

/******************************************************************************!
 * \fn open
 ******************************************************************************/
void
Output::open()
{
    if (mOled != nullptr) {
        return;
    }

#   if defined(__arm__) || defined(__aarch64__)
    try {
        mOled = new upm::SSD1306(0, DEVICE_ADDRESS);
    } catch (...) {
        mOled = new upm::SSD1306(1, DEVICE_ADDRESS);
    }
#   else
    mOled = new Terminal;
#   endif
    if (mOled == nullptr) {
        return;
    }
    mOled->clear();
    // SH1106 workarround
    for (unsigned int i = 0; i < LCD_ROWS; ++i) {
        mOled->setCursor(i, LCD_COLS - 2);
        mOled->write("  ");
    }
    mOled->dim(true);
    gOutputBuff[LCD_COLS] = '\0';
}

/******************************************************************************!
 * \fn write
 ******************************************************************************/
void
Output::write(const char* line1, const char* line2)
{
    if (mOled == nullptr) {
        return;
    }
    mOled->clear();

    std::string buff;
    buff = std::string(line1).substr(0, LCD_COLS);
    mOled->setCursor((LCD_ROWS >> 1) - 1, 0);
    mOled->write(buff);
    buff = std::string(line2).substr(0, LCD_COLS);
    mOled->setCursor((LCD_ROWS >> 1) + 1, 0);
    mOled->write(buff);
    nanoSleep(500000000);
}

/******************************************************************************!
 * \fn close
 ******************************************************************************/
void
Output::close()
{
    if (mOled == nullptr) {
        return;
    }
    mOled->clear();
    delete mOled;
    mOled = nullptr;
}

/******************************************************************************!
 * \fn screensaver
 ******************************************************************************/
void
Output::screensaver(Output* self)
{
    const unsigned int width = 5;
    const unsigned int height = 5;
    static int r = -1;

    while (self->loop) {
        self->save.wait(false);
        for (int i = 0; i < 20; ++i) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
            if (! self->save) {
                break;
            }
        }
        if (! self->save) {
            continue;
        }

        if (self->mOled == nullptr) {
            return;
        }
        self->mOled->clear();

        std::time_t time = std::time({});
        char timeString[std::size("dd-mm hh:mm")];
        if ((std::filesystem::status(self->mPath).permissions() &
             std::filesystem::perms::owner_read) ==
            std::filesystem::perms::owner_read) {
            std::strftime(std::data(timeString), std::size(timeString),
                          "%dX%m %H:%M", std::localtime(&time));
        } else {
            std::strftime(std::data(timeString), std::size(timeString),
                          "%d-%m %H:%M", std::localtime(&time));
        }

        if (r == -1) {
            srand(time);
        }
        r = rand() % ((LCD_COLS - (width - 1)) * (LCD_ROWS - (height - 1)));
        int x = r % (LCD_COLS - (width - 1));
        int y = r / (LCD_COLS - (width - 1));
        if (self->mOled->setCursor(y, x) != mraa::SUCCESS) {
            return;
        }

        timeString[width] = '\0';
        self->mOled->write(timeString);
        self->mOled->setCursor(y + height - 1, x);
        self->mOled->write(timeString + width + 1);

        if (std::filesystem::exists("/run/shutter.at")) {
            std::ifstream file("/run/shutter.at");
            std::string line;
            std::getline(file, line);
            if (! line.empty()) {
                self->mOled->setCursor(y + 2, x);
                self->mOled->write(line);
            }
        }
    }
}
