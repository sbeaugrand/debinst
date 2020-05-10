/******************************************************************************!
 * \file x11Bar.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "x11/display.h"
#include "x11/window.h"
#include "x11/event.h"
#include "x11Bar.h"
#include "common.h"

namespace X11 {

/******************************************************************************!
 * \fn ~Bar
 ******************************************************************************/
Bar::Bar()
    : mEvent(NULL)
{
    mDisplay = NULL;
    mWindow = NULL;
}

/******************************************************************************!
 * \fn ~Bar
 ******************************************************************************/
Bar::~Bar()
{
    if (mEvent != NULL) {
        delete mEvent;
    }
    if (mWindow != NULL) {
        delete mWindow;
    }
    if (mDisplay != NULL) {
        delete mDisplay;
    }
}

/******************************************************************************!
 * \fn draw
 ******************************************************************************/
void Bar::draw(uint8_t* buff) const
{
    int m = 0;
    int j = -1;
    for (int i = 0; i < (N >> 1); ++i) {
        if (m < buff[i]) {
            m = buff[i];
            j = i;
        }
    }
    mWindow->clear(mDisplay->black());
    if (j < 0) {
        mDisplay->setColor(mDisplay->white());
    } else if (j <= (1000 << M) / RATE) {
        mDisplay->setColor(0);
    } else if (j <= (2000 << M) / RATE) {
        mDisplay->setColor(1);
    } else if (j <= (3000 << M) / RATE) {
        mDisplay->setColor(2);
    } else if (j <= (4000 << M) / RATE) {
        mDisplay->setColor(3);
    } else {
        mDisplay->setColor(mDisplay->white());
    }
    for (j = 5; m << j > 255; --j) {
        ;
    }
    for (int i = 0; i < (N >> 1); ++i) {
        m = buff[i] << j;
        mWindow->fillRectangle(i << 4, 256 - m, 12, m);  // 12=2^4-3
    }
    mWindow->refresh();
}

/******************************************************************************!
 * \fn keyPress
 ******************************************************************************/
int Bar::keyPress(const Event* event)
{
    KeySym ks = event->getNextKey();

    switch (ks) {
    case XK_Escape: return EXIT;
    }
    return 0;
}

/******************************************************************************!
 * \fn run
 ******************************************************************************/
void Bar::run(Callback* loopObj,
              int (Callback::* loopFunc)(const Event*))
{
    try {
        mDisplay = new Display(4);
    } catch (const Exception& e) {
        return;
    }
    mDisplay->addColor(0, 255, 0, 0);
    mDisplay->addColor(1, 0, 255, 0);
    mDisplay->addColor(2, 0, 0, 255);
    mDisplay->addColor(3, 0, 255, 255);

    mWindow = new Window(mDisplay, N << 3, 256);
    mWindow->setTitle("x11Bar");
    mWindow->raise(mDisplay->black());

    mEvent = new Event(mDisplay);
    mEvent->addWindowWithExposeCB(mWindow);
    mEvent->addInput(mWindow, KeyPressMask, KeyPress, this,
                     (int (Callback::*)(const Event*)) & Bar::keyPress);
    mEvent->addInput(mWindow, 0, 0, loopObj, loopFunc);

    mEvent->run();
}

}  // namespace X11
