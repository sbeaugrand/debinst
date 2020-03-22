/******************************************************************************!
 * \file window.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <string.h>
#include "display.h"
#include "window.h"
#include "pixmap.h"

namespace X11 {

/******************************************************************************!
 * \fn Window
 ******************************************************************************/
Window::Window(Display* display, int w, int h)
    : Drawable(display, w, h)
{
    this->init(NULL);
}

/******************************************************************************!
 * \fn Window
 ******************************************************************************/
Window::Window(Display* display)
    : Drawable(display)
{
    this->init(NULL);
}

/******************************************************************************!
 * \fn Window
 ******************************************************************************/
Window::Window(Window* parent, int x, int y, int w, int h)
    : Drawable(parent->getDisplay(), x, y, w, h)
{
    this->init(parent);
}

/******************************************************************************!
 * \fn Window
 ******************************************************************************/
Window::Window(Window* parent)
    : Drawable(parent->getDisplay())
{
    this->init(parent);
}

/******************************************************************************!
 * \fn init
 * \brief Initialise certains attributs et complete la hierarchie des fenetres
 *   entree : la fenetre parente pour une sous-fenetre, 0 sinon
 ******************************************************************************/
void Window::init(Window* parent)
{
    mWindow = 0;
    if ((mParent = parent)) {
        mParent->addChild(this);
    }
    mChilds = new std::list<Window*>;
    setTitle("");
}

/******************************************************************************!
 * \fn create
 * \brief Demande de creation de la fenetre et de sa pixmap associee aupres du
 *        serveur X
 ******************************************************************************/
void Window::create(ULong color)
{
    if (mWindow != 0) {
        return;
    }

    mWindow =
        XCreateSimpleWindow(mX11Display,
                            (mParent) ? mParent->id() : mDisplay->root(),
                            mIndic.x, mIndic.y,
                            mIndic.width, mIndic.height,
                            0, color, color);

    // Selection d'evenements pour la fenetre
    mEventMask = 0;

    // Creation de la mPixmap associee a la fenetre
    mPixmap = new Pixmap(mDisplay, mIndic.width, mIndic.height);
    mX11Pixmap = mPixmap->id();

    // Enlever les evenements provenant des copies de zones de mPixmap
    XSetGraphicsExposures(mX11Display, mGC, False);

    //addInput(0);
    setTitle(mTitle);

    this->clear(color);
}

/******************************************************************************!
 * \fn ~Window
 ******************************************************************************/
Window::~Window()
{
    delete mChilds;
    delete mPixmap;
    if (mWindow) {
        XDestroyWindow(mX11Display, mWindow);
    }
}

/******************************************************************************!
 * \fn clear
 ******************************************************************************/
void Window::clear(ULong color)
{
    mPixmap->clear(color);
}

/******************************************************************************!
 * \fn setPosition
 * \brief Positionne la fenetre dans sa fenetre parente
 *   entree : les coordonnees x et y du point superieur gauche de la fenetre
 ******************************************************************************/
void Window::setPosition(int x, int y)
{
    Drawable::setPosition(x, y);
    if (mWindow) {
        XMoveWindow(mX11Display, mWindow, x, y);
    }
}

/******************************************************************************!
 * \fn setSize
 * \brief Positionne ou change la taille de la fenetre
 *   entree : la largeur et la hauteur en pixels
 ******************************************************************************/
void Window::setSize(int w, int h)
{
    Drawable::setSize(w, h);
    if (mWindow) {
        XResizeWindow(mX11Display, mWindow, w, h);
        mPixmap->setSize(w, h);
        mX11Pixmap = mPixmap->id();
    }
}

/******************************************************************************!
 * \fn addInput
 * \brief Ajoute un evenement a la liste des evenements interceptes par la
 *        fenetre
 *   entree : un masque d'evenement(s)
 ******************************************************************************/
void Window::addInput(ULong mask)
{
    mEventMask |= mask;
    if (mWindow) {
        XSelectInput(mX11Display, mWindow, mEventMask);
    }
}

/******************************************************************************!
 * \fn delInput
 * \brief Enleve un ou tous les evenements a la liste des evenements
 *        interceptes par la fenetre
 *   entree : un masque d'evenement(s) ou rien
 ******************************************************************************/
void Window::delInput(ULong mask)
{
    mEventMask &= ~mask;
    if (mWindow) {
        XSelectInput(mX11Display, mWindow, mEventMask);
    }
}

/******************************************************************************!
 * \fn delInput
 ******************************************************************************/
void Window::delInput()
{
    mEventMask = 0;
    if (mWindow) {
        XSelectInput(mX11Display, mWindow, mEventMask);
    }
}

/******************************************************************************!
 * \fn delInput
 * \brief Positionne le titre de la fenetre (visible dans la barre de titre)
 *   entree : une chaine de caracteres
 ******************************************************************************/
void Window::setTitle(const char* title)
{
    if (const_cast<char*>(title) != mTitle) {
        strcpy(mTitle, title);
    }
    if (mWindow) {
        XSetStandardProperties(mX11Display, mWindow, mTitle, mTitle,
                               None, NULL, 0, &mIndic);
    }
}

/******************************************************************************!
 * \fn refresh
 ******************************************************************************/
void Window::refresh()
{
    XCopyArea(mX11Display, mX11Pixmap, mWindow, mGC,
              0, 0, mIndic.width, mIndic.height, 0, 0);
}

/******************************************************************************!
 * \fn refresh
 ******************************************************************************/
void Window::refresh(int x1, int y1, int x2, int y2)
{
    XCopyArea(mX11Display, mX11Pixmap, mWindow, mGC,
              (x1 < x2) ? x1 : x2,
              (y1 < y2) ? y1 : y2,
              (x2 > x1) ? x2 - x1 + 1 : x1 - x2 + 1,
              (y2 > y1) ? y2 - y1 + 1 : y1 - y2 + 1,
              (x1 < x2) ? x1 : x2,
              (y1 < y2) ? y1 : y2);
}

/******************************************************************************!
 * \fn refreshAll
 ******************************************************************************/
void Window::refreshAll()
{
    flush();

    std::list<Window*>::const_iterator it;
    for (it = mChilds->begin();
         it != mChilds->end(); ++it) {
        (*it)->refreshAll();
    }

    if (parentIsRoot()) {
        XFlush(mX11Display);
    }
}

/******************************************************************************!
 * \fn flush
 ******************************************************************************/
void Window::flush()
{
    XFlush(mX11Display);
}

/******************************************************************************!
 * \fn raise
 ******************************************************************************/
void Window::raise(ULong color)
{
    this->create(color);
    XMapRaised(mX11Display, mWindow);

    std::list<Window*>::const_iterator it;
    for (it = mChilds->begin();
         it != mChilds->end(); ++it) {
        (*it)->raise(color);
    }

    refresh();
}

/******************************************************************************!
 * \fn destroy
 ******************************************************************************/
void Window::destroy()
{
    mWindow = 0;
    delete this;
}

/******************************************************************************!
 * \fn operator==
 ******************************************************************************/
int operator==(const Window& w1, const Window& w2)
{
    return w1.mWindow == w2.mWindow;
}

/******************************************************************************!
 * \fn operator!=
 ******************************************************************************/
int operator!=(const Window& w1, const Window& w2)
{
    return w1.mWindow != w2.mWindow;
}

}  // namespace X11
