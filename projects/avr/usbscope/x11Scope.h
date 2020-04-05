/******************************************************************************!
 * \file x11scope.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef _X11_SCOPE_H_
#define _X11_SCOPE_H_

#include "x11/event.h"

namespace X11 {

class Display;
class Window;

class Scope : public Callback
{
public:
    Scope();
    ~Scope();
    void run(Callback * loopObj, int (Callback::* loopFunc)(const Event*));
    void drawPoints(double time, double val1, double val2 = -88.0);
    int keyPress(const Event* event);

private:
    void drawMenu() const;
    void drawGrid() const;

    Display* mDisplay;
    Window* mWindow;
    Event* mEvent;
    int mVal1Offset;
    int mVal2Offset;
    double mDivScaleX;
    double mDivScaleY;
    enum MENU_SELECT {
        MENU_DIV_SCALE_X = 0,
        MENU_DIV_SCALE_Y,
        MENU_POS_V1,
        MENU_POS_V2,
        MENU_SIZE
    };
    int mMenuSelect;
};

}  // namespace X11

#endif
