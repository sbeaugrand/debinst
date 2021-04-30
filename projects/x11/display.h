/******************************************************************************!
 * \file display.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef _X11_DISPLAY_H_
#define _X11_DISPLAY_H_

#include <X11/Xlib.h>
#include <exception>

typedef unsigned long ULong;

namespace X11 {

class Display
{
public:
    explicit Display(int colormapSize = 0);
    Display(int argc, char** argv, char** arge, int colormapSize = 0);
    ~Display();
    void open(char* display = NULL);
    void close();

    ::Display* id()         const { return mDisplay; }
    GC gc()                 const { return mGC; }
    ::Window root()         const { return mRoot;  }
    int depth()             const { return mDepth; }
    ULong black()           const { return mBlack; }
    ULong white()           const { return mWhite; }
    int getFontAscent()     const { return mFontAscent; }
    int getFontDescent()    const { return mFontDescent; }
    XColor getXColor(int n) const { return mColormap[n]; }
    ULong getColor(int n)   const { return mColormap[n].pixel; }
    int nbrColor()          const { return mNbColor; }

    void addColor(int n, int r, int g, int b);
    void setColor(int n) {
        XSetForeground(mDisplay, mGC, mColormap[n].pixel);
    }
    void setColor(ULong c) {
        XSetForeground(mDisplay, mGC, c);
    }
    int textWidth(const char* s);
    void flush() { XFlush(mDisplay); }

private:
    ::Display * mDisplay;
    GC mGC;
    XFontStruct* mFontStruct;
    int mFontAscent;
    int mFontDescent;
    Colormap mColormapDef;
    XColor* mColormap;
    int mColormapSize;
    int mNbColor;
    int mScreen;
    ::Window mRoot;
    int mDepth;
    ULong mBlack;
    ULong mWhite;
};

class Exception : public std::exception
{
public:
    Exception() {};
    virtual ~Exception() throw() {};
};

}  // namespace X11

#endif
