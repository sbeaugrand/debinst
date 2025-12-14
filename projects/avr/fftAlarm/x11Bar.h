/******************************************************************************!
 * \file x11Bar.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef _X11_BAR_H_
#define _X11_BAR_H_

#include <stdint.h>
#include "x11/event.h"

namespace X11 {

class Display;
class Window;

class Bar : public Callback
{
public:
    Bar();
    ~Bar() override;
    void run(Callback * loopObj, int (Callback::* loopFunc)(const Event*));
    void draw(const uint8_t* buff) const;
    int keyPress(const Event* event);

private:
    Display* mDisplay;
    Window* mWindow;
    Event* mEvent;
};

}  // namespace X11

#endif
