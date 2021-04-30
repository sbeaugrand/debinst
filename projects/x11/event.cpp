/******************************************************************************!
 * \file event.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include <algorithm>
#include <X11/XKBlib.h>
#include "event.h"
#include "display.h"
#include "window.h"

namespace X11 {

/******************************************************************************!
 * \class ExposeCallback
 ******************************************************************************/
class ExposeCallback : public Callback
{
public:
    int expose(const Event* event)
    {
        if (event->mEvent.xexpose.count == 0) {
            const std::list<Input>& lst = event->getInputList();
            std::list<Input>::const_iterator it = lst.begin();
            Window* window = nullptr;
            while ((it != lst.end() &&
                    (window = (*it).getWindow()) &&
                    window->id() != event->mEvent.xexpose.window) ||
                   (it != lst.end() && (*it).getWindow() == 0)) {
                ++it;
            }
            if (window != nullptr && it != lst.end()) {
                window->refresh();
            }
        }
        return 0;
    }
};
static ExposeCallback gExposeCallback;

/******************************************************************************!
 * \class MappingNotifyCallback
 ******************************************************************************/
class MappingNotifyCallback : public Callback
{
public:
    int mappingNotify(const Event* event)
    {
        XRefreshKeyboardMapping(&const_cast<Event*>(event)->mEvent.xmapping);
        return 0;
    }
};
static MappingNotifyCallback gMappingNotifyCallback;

/******************************************************************************!
 * \fn operator==
 ******************************************************************************/
bool operator==(const Input& i1, const Input& i2)
{
    return ! (i1 != i2);
}

/******************************************************************************!
 * \fn operator!=
 ******************************************************************************/
bool operator!=(const Input& i1, const Input& i2)
{
    int mask = i1.mCmpMask & i2.mCmpMask;

    if ((mask & EVENT_CMP_TYPE) && i1.mType != i2.mType) {
        return true;
    }
    if ((mask & EVENT_CMP_WIN) && i1.mWinId != i2.mWinId) {
        return true;
    }
    if ((mask & EVENT_CMP_MASK) && i1.mMask != i2.mMask) {
        return true;
    }
    return false;
}

/******************************************************************************!
 * \fn Event
 ******************************************************************************/
Event::Event(Display* display) :
    mCallbackObj(NULL),
    mCallbackFunc(NULL)
{
    mDisplay = display->id();
    addInput(0, 0, MappingNotify, &gMappingNotifyCallback,
             (int(Callback::*) (const Event*))
             & MappingNotifyCallback::mappingNotify);
}

/******************************************************************************!
 * \fn ~Event
 ******************************************************************************/
Event::~Event()
{
}

/******************************************************************************!
 * \fn addWindowWithExposeCB
 ******************************************************************************/
void Event::addWindowWithExposeCB(Window* w)
{
    addInput(w, ExposureMask, Expose, &gExposeCallback,
             (int(Callback::*) (const Event*))
             & ExposeCallback::expose);
}

/******************************************************************************!
 * \fn addInput
 ******************************************************************************/
void Event::addInput(Window* window, long mask, long type, Callback* cbObj,
                     int (Callback::* cbFunc)(const Event*))
{
    if (mask || type) {
        Input input(window, mask, type, cbObj, cbFunc);
        input.mCmpMask = 0;
        if (window) {
            window->addInput(mask);
            input.mWinId = window->id();
            input.mCmpMask |= EVENT_CMP_WIN;
        } else {
            input.mWinId = 0;
        }
        input.mCmpMask |= (mask) ? EVENT_CMP_MASK : 0;
        input.mCmpMask |= (type) ? EVENT_CMP_TYPE : 0;
        mInputList.push_back(input);
    } else {
        mCallbackObj = cbObj;
        mCallbackFunc = cbFunc;
    }
    if (window && ! window->id()) {
        std::cerr << "warning : X11::Event::addInput"
            " identificateur de fenetre non initialise"
            " dans X11::Window (fenetre non projetee)" << std::endl;
    }
}

/******************************************************************************!
 * \fn delInput
 ******************************************************************************/
void Event::delInput(Window* window)
{
    std::list<Input>::iterator it;
    Window* w;
    for (it = mInputList.begin();
         it != mInputList.end();) {
        if ((w = (*it).getWindow()) && w->id() == window->id()) {
            it = mInputList.erase(it);
        } else {
            ++it;
        }
    }
}

/******************************************************************************!
 * \fn run
 ******************************************************************************/
int Event::run()
{
    std::list<Input>::iterator it;
    Input input;
    Callback* cbObj;
    int (Callback::* cbFunc)(const Event*);

#ifndef NDEBUG
    std::cout << "liste des evenements geres :" << std::endl;
    for (it = mInputList.begin();
         it != mInputList.end(); ++it) {
        std::cerr << "event " << (*it).mType
                  << " window " << (*it).mWinId << std::endl;
    }
#endif

    input.mCmpMask = EVENT_CMP_TYPE | EVENT_CMP_WIN;
    mLoop = True;
    while (mLoop) {
        if (XPending(mDisplay)) {
            XNextEvent(mDisplay, &mEvent);
#ifndef NDEBUG
            std::cerr << "receive event " << mEvent.type
                      << " from window " << mEvent.xany.window << std::endl;
#endif
            input.mType = mEvent.type;
            input.mWinId = mEvent.xany.window;
            it = std::find(mInputList.begin(), mInputList.end(), input);
            if (it != mInputList.end() &&
                (cbObj = (*it).mCallbackObj) &&
                (cbFunc = (*it).mCallbackFunc) &&
                (cbObj->*cbFunc)(this) == EXIT) {
                mLoop = False;
            } else if (mEvent.type == MappingNotify) {
                // Pour les evenements ne dependant pas d'une fenetre
                // comme celui de type MappingNotify
                input.mCmpMask = EVENT_CMP_TYPE;
                it = std::find(mInputList.begin(), mInputList.end(), input);
                if (it != mInputList.end() &&
                    (cbObj = (*it).mCallbackObj) &&
                    (cbFunc = (*it).mCallbackFunc) &&
                    (cbObj->*cbFunc)(this) == EXIT) {
                    mLoop = False;
                }
                input.mCmpMask = EVENT_CMP_TYPE | EVENT_CMP_WIN;
            }
        }
        if (mCallbackObj) {
            (mCallbackObj->*mCallbackFunc)(this);
        }
    }
    return 0;
}

/******************************************************************************!
 * \fn getNextKey
 ******************************************************************************/
KeySym Event::getNextKey() const
{
    //return XKeycodeToKeysym(mDisplay, mEvent.xkey.keycode, 0);
    return XkbKeycodeToKeysym(mDisplay, mEvent.xkey.keycode, 0,
                              (mEvent.xkey.state & ShiftMask) ? 1 : 0);
}

/******************************************************************************!
 * \fn getNextState
 ******************************************************************************/
int Event::getNextState() const
{
    return mEvent.xkey.state;
}

}  // namespace X11
