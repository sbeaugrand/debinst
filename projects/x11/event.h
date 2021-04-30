/******************************************************************************!
 * \file event.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef _X11_EVENT_H_
#define _X11_EVENT_H_

#include <list>
#include <X11/Xlib.h>
#include <X11/keysym.h>

#define EVENT_CMP_WIN 1
#define EVENT_CMP_MASK 2
#define EVENT_CMP_TYPE 4
#define EXIT 1

namespace X11 {

class Display;
class Window;
class Event;

/******************************************************************************!
 * \class Callback
 ******************************************************************************/
class Callback
{
public:
    Callback() {}
    virtual ~Callback() {}
};

/******************************************************************************!
 * \class Input
 ******************************************************************************/
class Input
{
    friend class Event;

public:
    Input() { }
    Input(Window* w, long m, long t, Callback* cbObj,
          int(Callback::* cbFunc)(const Event*)) :
        mWindow(w), mMask(m), mType(t),
        mCallbackObj(cbObj), mCallbackFunc(cbFunc) { }
    Window* getWindow() const { return mWindow; }
    friend bool operator==(const Input& i1, const Input& i2);
    friend bool operator!=(const Input& i1, const Input& i2);

private:
    Window* mWindow;
    ::Window mWinId;
    long mMask;
    long mType;
    int mCmpMask = 0;
    Callback* mCallbackObj;
    int (Callback::* mCallbackFunc)(const Event*);
};

/******************************************************************************!
 * \class Event
 ******************************************************************************/
class Event
{
public:
    explicit Event(Display* display);
    ~Event();
    const std::list<Input>& getInputList() const { return mInputList; }
    void addWindowWithExposeCB(Window* w);
    void addInput(Window * window, long mask, long type, Callback * cbObj,
                  int (Callback::* cbFunc)(const Event*));
    void delInput(Window* window);
    int run();
    KeySym getNextKey() const;
    int getNextState() const;

public:
    XEvent mEvent;

private:
    ::Display * mDisplay;
    Callback* mCallbackObj;
    int (Callback::* mCallbackFunc)(const Event*);
    Bool mLoop;
    std::list<Input> mInputList;
};

}  // namespace X11

#endif
