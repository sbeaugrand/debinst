/******************************************************************************!
 * \file x11scope.cpp
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
#include "x11Scope.h"

#define DIV_COUNT 10
#define DIV_SIZE 60
#define MENU_BORDER 10

namespace X11 {

/******************************************************************************!
 * \fn Scope
 ******************************************************************************/
Scope::Scope()
    : mEvent(NULL)
{
    mDisplay = NULL;
    mWindow = NULL;
    mVal1Offset = 0;
    mVal2Offset = 0;
    mDivScaleX = 1.0;
    mDivScaleY = 1.0;
    mMenuSelect = MENU_DIV_SCALE_X;
}

/******************************************************************************!
 * \fn ~Scope
 ******************************************************************************/
Scope::~Scope()
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
 * \fn drawMenu
 ******************************************************************************/
void Scope::drawMenu() const
{
    static char str[32];
    int p = mDisplay->getFontAscent() + mDisplay->getFontDescent();
    int y = mWindow->getHeight() - p;

    for (int i = MENU_SIZE - 1; i >= 0; --i) {
        if (i == mMenuSelect) {
            mDisplay->setColor(1);
        } else {
            mDisplay->setColor(2);
        }
        switch (i) {
        case MENU_DIV_SCALE_X:
            if (mDivScaleX < 1.0) {
                sprintf(str, "1.0 div = %.1f s", 1 / mDivScaleX);
            } else {
                sprintf(str, "%.1f div = 1.0 s", mDivScaleX);
            }
            mWindow->drawString(p, y, str, strlen(str));
            break;
        case MENU_DIV_SCALE_Y:
            if (mDivScaleY < 1.0) {
                sprintf(str, "1.0 div = %.1f V", 1 / mDivScaleY);
            } else {
                sprintf(str, "%.1f div = 1.0 V", mDivScaleY);
            }
            mWindow->drawString(p, y, str, strlen(str));
            break;
        case MENU_POS_V1:
            sprintf(str, "offset 1 = %dV", mVal1Offset);
            mWindow->drawString(p, y, str, strlen(str));
            break;
        case MENU_POS_V2:
            sprintf(str, "offset 2 = %dV", mVal2Offset);
            mWindow->drawString(p, y, str, strlen(str));
            break;
        default:
            fprintf(stderr, "error: menu select\n");
        }
        y -= p;
    }
}

/******************************************************************************!
 * \fn drawGrid
 ******************************************************************************/
void Scope::drawGrid() const
{
    int w = mWindow->getWidth();
    int h = mWindow->getHeight();
    int x;
    int y;
    int p;
    int c;

    mDisplay->setColor(mDisplay->white());
    mWindow->clear(mDisplay->black());

    y = h >> 1;
    p = w / (DIV_COUNT * 10);
    c = 0;
    for (x = 0; x < w; x += p) {
        if (c == 0) {
            mDisplay->setColor(2);
            mWindow->drawLine(x, 0, x, h);
            mDisplay->setColor(mDisplay->white());
            mWindow->drawLine(x, y - 3, x, y + 3);
        } else {
            mWindow->drawLine(x, y - 1, x, y + 1);
        }
        ++c;
        if (c == 10) {
            c = 0;
        }
    }

    x = w >> 1;
    p = h / (DIV_COUNT * 10);
    c = 0;
    for (y = 0; y < h; y += p) {
        if (c == 0) {
            mDisplay->setColor(2);
            mWindow->drawLine(0, y, w, y);
            mDisplay->setColor(mDisplay->white());
            mWindow->drawLine(x - 3, y, x + 3, y);
        } else {
            mWindow->drawLine(x - 1, y, x + 1, y);
        }
        ++c;
        if (c == 10) {
            c = 0;
        }
    }

    mWindow->drawLine(0, h >> 1, w, h >> 1);
    mWindow->drawLine(w >> 1, 0, w >> 1, h);

    drawMenu();

    mWindow->refresh();
}

/******************************************************************************!
 * \fn drawPoints
 ******************************************************************************/
void Scope::drawPoints(double time, double val1, double val2)
{
    static double x1v1 = 0.0;
    static double y1v1 = 0.0;
    static double y1v2 = 0.0;
    static double timeOffset = -DIV_COUNT;

    if (time - timeOffset >= DIV_COUNT / mDivScaleX) {
        this->drawGrid();
        timeOffset += DIV_COUNT / mDivScaleX;
        x1v1 = time - timeOffset;
        y1v1 = val1;
        y1v2 = val2;
        return;
    }

    double x2v1 = time - timeOffset;
    double y2v1 = val1;

    int x1 = x1v1 * DIV_SIZE * mDivScaleX;
    int y1 = ((DIV_COUNT >> 1) - (mVal1Offset + y1v1) * mDivScaleY) * DIV_SIZE;
    int x2 = x2v1 * DIV_SIZE * mDivScaleX;
    int y2 = ((DIV_COUNT >> 1) - (mVal1Offset + y2v1) * mDivScaleY) * DIV_SIZE;
    mDisplay->setColor(0);
    mWindow->drawLine(x1, y1, x2, y2);
    mWindow->refresh(x1, y1, x2, y2);
    mWindow->flush();

    x1v1 = x2v1;
    y1v1 = y2v1;

    if (val2 > -88.0) {
        double y2v2 = val2;

        y1 = ((DIV_COUNT >> 1) - (mVal2Offset + y1v2) * mDivScaleY) * DIV_SIZE;
        y2 = ((DIV_COUNT >> 1) - (mVal2Offset + y2v2) * mDivScaleY) * DIV_SIZE;
        mDisplay->setColor(1);
        mWindow->drawLine(x1, y1, x2, y2);
        mWindow->refresh(x1, y1, x2, y2);
        mWindow->flush();

        y1v2 = y2v2;
    }
}

/******************************************************************************!
 * \fn keyPress
 ******************************************************************************/
int Scope::keyPress(const Event* event)
{
    KeySym ks = event->getNextKey();
    double inc = (event->getNextState() & ShiftMask) ? 0.1 : 1.0;

    switch (ks) {
    case XK_Escape: return EXIT;
    case XK_Up:
        mMenuSelect = (mMenuSelect > 0) ? mMenuSelect - 1 : MENU_SIZE - 1;
        drawMenu();
        mWindow->refresh();
        return 0;
    case XK_Down:
        mMenuSelect = (mMenuSelect + 1) % MENU_SIZE;
        drawMenu();
        mWindow->refresh();
        return 0;
    }
    switch (mMenuSelect) {
    case MENU_DIV_SCALE_X:
        if (ks == XK_Left) {
            if (mDivScaleX >= 1.0) {
                mDivScaleX += inc;
            } else {
                mDivScaleX = 1 / (1 / mDivScaleX - inc);
            }
            drawGrid();
        } else if (ks == XK_Right) {
            if (mDivScaleX > 1.0) {
                mDivScaleX -= inc;
            } else {
                mDivScaleX = 1 / (1 / mDivScaleX + inc);
            }
            drawGrid();
        }
        break;
    case MENU_DIV_SCALE_Y:
        if (ks == XK_Left) {
            if (mDivScaleY >= 1.0) {
                mDivScaleY += inc;
            } else {
                mDivScaleY = 1 / (1 / mDivScaleY - inc);
            }
            drawGrid();
        } else if (ks == XK_Right) {
            if (mDivScaleY > 1.0) {
                mDivScaleY -= inc;
            } else {
                mDivScaleY = 1 / (1 / mDivScaleY + inc);
            }
            drawGrid();
        }
        break;
    case MENU_POS_V1:
        if (ks == XK_Left) {
            --mVal1Offset;
            drawGrid();
        } else if (ks == XK_Right) {
            ++mVal1Offset;
            drawGrid();
        }
        break;
    case MENU_POS_V2:
        if (ks == XK_Left) {
            --mVal2Offset;
            drawGrid();
        } else if (ks == XK_Right) {
            ++mVal2Offset;
            drawGrid();
        }
        break;
    }
    return 0;
}

/******************************************************************************!
 * \fn run
 ******************************************************************************/
void Scope::run(Callback* loopObj,
                int (Callback::* loopFunc)(const Event*))
{
    try {
        mDisplay = new Display(3);
    } catch (const Exception& e) {
        return;
    }
    mDisplay->addColor(0, 0, 255, 0);
    mDisplay->addColor(1, 255, 0, 0);
    mDisplay->addColor(2, 15, 15, 15);

    mWindow = new Window(mDisplay,
                         DIV_SIZE * DIV_COUNT + 1,
                         DIV_SIZE * DIV_COUNT + 1);
    mWindow->setTitle("Oscilloscope");
    mWindow->raise(mDisplay->black());

    mEvent = new Event(mDisplay);
    mEvent->addWindowWithExposeCB(mWindow);
    mEvent->addInput(mWindow, KeyPressMask, KeyPress, this,
                     (int (Callback::*)(const Event*)) & Scope::keyPress);
    mEvent->addInput(mWindow, 0, 0, loopObj, loopFunc);

    mEvent->run();
}

}  // namespace X11
