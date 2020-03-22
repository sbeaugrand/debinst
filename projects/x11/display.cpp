/******************************************************************************!
 * \file display.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include "display.h"

namespace X11 {

/******************************************************************************!
 * \fn Display
 ******************************************************************************/
Display::Display(int colormapSize) :
    mDisplay(NULL),
    mColormapSize(colormapSize),
    mNbColor(0)
{
    this->open(::getenv("DISPLAY"));
}

/******************************************************************************!
 * \fn Display
 ******************************************************************************/
Display::Display(int argc, char** argv, char**, int colormapSize) :
    mDisplay(NULL),
    mColormapSize(colormapSize),
    mNbColor(0)
{
    char* display = NULL;
    if (argc > 1 && argv != NULL) {
        for (int i = 1; i < argc; i++) {
            if (strcmp(argv[i], "-display") == 0 && (i + 1) < argc) {
                display = argv[i + 1];
                break;
            }
        }
    }
    this->open(display);
}

/******************************************************************************!
 * \fn open
 ******************************************************************************/
void Display::open(char* display)
{
    if (mDisplay != NULL) {
        return;
    }

    if ((mDisplay = XOpenDisplay(display)) == NULL) {
        std::cerr << "error: XOpenDisplay" << std::endl;
        if (display != NULL) {
            std::cerr << "DISPLAY=" << display << std::endl;
        }
        throw Exception();
    }
    mScreen = DefaultScreen(mDisplay);
    mRoot = DefaultRootWindow(mDisplay);
    mDepth = XDefaultDepth(mDisplay, mScreen);
    mBlack = BlackPixel(mDisplay, mScreen);
    mWhite = WhitePixel(mDisplay, mScreen);

    // Interception des evenements ResizeRequest par la fenetre racine
    // pour que les fenetres top-niveau ne les recoivent pas
    // std::cout << "root_input_mask = " << std::hex
    //           << XEventMaskOfScreen(XDefaultScreenOfDisplay(display))
    //           << std::endl;
    XDefaultScreenOfDisplay(mDisplay)->root_input_mask |= ResizeRedirectMask;

    // Creation du contexte graphique par defaut
    mGC = XCreateGC(mDisplay, mRoot, 0, NULL);

    // Informations sur la police de caracteres par defaut
    if ((mFontStruct = XLoadQueryFont(mDisplay, "fixed"))) {
        XCharStruct charStruct;
        int direction;
        XSetFont(mDisplay, mGC, mFontStruct->fid);
        XTextExtents(mFontStruct, "", 0, &direction, &mFontAscent,
                     &mFontDescent, &charStruct);
    } else {
        std::cerr << "error: XLoadQueryFont" << std::endl;
    }

    // Creation de la palette de couleurs
    mColormapDef = DefaultColormap(mDisplay, mScreen);
    if (mColormapSize == 0) {
        mColormapSize = 1 << mDepth;
    }
    mColormap = new XColor[mColormapSize];
}

/******************************************************************************!
 * \fn ~Display
 ******************************************************************************/
Display::~Display()
{
    if (mDisplay != NULL) {
        this->close();
    }
}

/******************************************************************************!
 * \fn close
 ******************************************************************************/
void Display::close()
{
    delete[] mColormap;
    mColormap = NULL;
    if (mFontStruct) {
        XFreeFont(mDisplay, mFontStruct);
        mFontStruct = NULL;
    }
    XFreeGC(mDisplay, mGC);
    mGC = NULL;
    XCloseDisplay(mDisplay);
    mDisplay = NULL;
}

/******************************************************************************!
 * \fn addColor
 ******************************************************************************/
void Display::addColor(int n, int r, int g, int b)
{
    if (n < 0 || n >= mColormapSize) {
        std::cerr << "error: X11::Display::addColor" << std::endl;
        return;
    }
    mColormap[n].red = r << 8;
    mColormap[n].green = g << 8;
    mColormap[n].blue = b << 8;
    if (XAllocColor(mDisplay, mColormapDef, mColormap + n)) {
        mNbColor++;
    }
}

/******************************************************************************!
 * \fn textWidth
 ******************************************************************************/
int Display::textWidth(const char* s)
{
    if (mFontStruct) {
        return XTextWidth(mFontStruct, s, strlen(s));
    } else {
        std::cerr << "error: X11::Display::textWidth" << std::endl;
        return 0;
    }
}

}  // namespace X11
