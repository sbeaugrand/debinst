/******************************************************************************!
 * \file Input.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#if defined(__arm__) || defined(__aarch64__)
# include <fcntl.h>
# include <lirc/lirc_client.h>
#endif
#include "Input.h"
#include "log.h"

/******************************************************************************!
 * \fn Input
 ******************************************************************************/
Input::Input()
{
    this->open();
}

/******************************************************************************!
 * \fn ~Input
 ******************************************************************************/
Input::~Input()
{
    this->close();
}

/******************************************************************************!
 * \fn open
 ******************************************************************************/
void
Input::open()
{
#   if defined(__arm__) || defined(__aarch64__)
    mLircSocket = lirc_init("irexec", 1);
    if (mLircSocket == -1) {
        ERROR("lirc_init");
    }
    if (fcntl(mLircSocket, F_SETFL,
              fcntl(mLircSocket, F_GETFL, 0) | O_NONBLOCK) == -1) {
        ERROR("fcntl");
    }
#   endif

    mThread = std::thread(Input::run, this);
}

/******************************************************************************!
 * \fn close
 ******************************************************************************/
void
Input::close()
{
    this->loop = false;
    mThread.join();

#   if defined(__arm__) || defined(__aarch64__)
    lirc_deinit();
#   endif
}

/******************************************************************************!
 * \fn run
 ******************************************************************************/
void
Input::run(Input* self)
{
    while (self->loop) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));

        self->key = KEY_UNDEFINED;

#       if defined(__arm__) || defined(__aarch64__)
        char* code;
        if (lirc_nextcode(&code) != 0 || code == NULL) {
            continue;
        }

        char* backup = strdup(code);
        if (backup == NULL) {
            ERROR("strdup");
            free(code);
            continue;
        }
        strtok(backup, " ");
        strtok(NULL, " ");
        char* button = strtok(NULL, " ");
        if (button == NULL) {
            ERROR("strtok");
            free(backup);
            free(code);
            continue;
        }
        free(backup);
        free(code);
#       else
        std::string line;
        std::cin >> line;
        const char* button = line.c_str();
#       endif

        using namespace std::literals;
        /*  */ if (button == "KEY_BACK"s) {
            self->key = KEY_BACK;
        } else if (button == "KEY_DOWN"s) {
            self->key = KEY_DOWN;
        } else if (button == "KEY_LEFT"s) {
            self->key = KEY_LEFT;
        } else if (button == "KEY_MODE"s) {
            self->key = KEY_MODE;
        } else if (button == "KEY_OK"s) {
            self->key = KEY_OK;
        } else if (button == "KEY_PLAYPAUSE"s) {
            self->key = KEY_PLAYPAUSE;
        } else if (button == "KEY_RIGHT"s) {
            self->key = KEY_RIGHT;
        } else if (button == "KEY_SETUP"s) {
            self->key = KEY_SETUP;
        } else if (button == "KEY_UP"s) {
            self->key = KEY_UP;
        } else {
            ERROR("KEY_UNDEFINED " << button);
            self->key = KEY_UNDEFINED;
        }
        if (self->key != KEY_UNDEFINED) {
            self->hasEvent = true;
            self->hasEvent.notify_one();
        }
    }
}
