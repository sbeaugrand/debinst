/******************************************************************************!
 * \file Output.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#include <thread>
#if defined(__arm__) || defined(__aarch64__)
# include <upm/ssd1306.hpp>
#else
# include "Terminal.h"
#endif

/******************************************************************************!
 * \class Output
 ******************************************************************************/
class Output
{
public:
#   if defined(__arm__) || defined(__aarch64__)
    static constexpr unsigned int LCD_ROWS = upm::SSD1306_LCDHEIGHT >> 3;
#   else
    static constexpr unsigned int LCD_ROWS = 8;
#   endif
    static constexpr unsigned int LCD_COLS = 16;
    static constexpr int LCD_SHIFT = LCD_COLS >> 1;
    Output();
    ~Output();
    void open();
    void write(std::string_view line1,
               std::string_view line2,
               std::string_view line3,
               std::string_view line4);
    void close();
    void screensaver();
    static void run(Output* self);

    std::atomic_bool loop = true;
    std::atomic_bool save = false;
    std::string musicDirectory = "/mnt/mp3/mp3";
private:
#   if defined(__arm__) || defined(__aarch64__)
    upm::SSD1306* mOled = nullptr;
#   else
    Terminal* mOled = nullptr;
#   endif
    std::thread mScreensaverThread;
    std::mutex mMutex;
};
