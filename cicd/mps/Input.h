/******************************************************************************!
 * \file Input.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#include <thread>
#if defined(__arm__) || defined(__aarch64__)
#else
# include "Terminal.h"
#endif

/******************************************************************************!
 * \class Input
 ******************************************************************************/
class Input
{
public:
    enum Key {
        KEY_UP,
        KEY_DOWN,
        KEY_LEFT,
        KEY_RIGHT,
        KEY_OK,
        KEY_SETUP,
        KEY_BACK,
        KEY_MODE,
        KEY_PLAYPAUSE,
        KEY_UNDEFINED
    };
    Input();
    ~Input();
    void open();
    void close();
    static void run(Input* self);

    std::atomic_bool loop = true;
    std::atomic_bool hasEvent = false;
    Key key;
private:
#   if defined(__arm__) || defined(__aarch64__)
    int mLircSocket = -1;
#   else
    Terminal* mOled = nullptr;
#   endif
    std::thread mThread;
};
