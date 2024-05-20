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
    explicit Output(const std::string& path);
    ~Output();
    void open();
    void write(const char* line1, const char* line2);
    void close();
    static void screensaver(Output* self);

    std::atomic_bool loop = true;
    std::atomic_bool save = false;
private:
    const std::string mPath;
#   if defined(__arm__) || defined(__aarch64__)
    upm::SSD1306* mOled = nullptr;
#   else
    Terminal* mOled = nullptr;
#   endif
    std::thread mScreensaverThread;
};
