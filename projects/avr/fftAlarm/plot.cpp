/******************************************************************************!
 * \file plot.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include "x11Bar.h"
#include "common.h"

X11::Bar* gBar = NULL;

/******************************************************************************!
 * \class LoopCallback
 ******************************************************************************/
class LoopCallback : public X11::Callback
{
    uint8_t buff[N >> 1];

public:
    int loop(const X11::Event*)
    {
        static ssize_t t = 0;

        ssize_t s = read(STDIN_FILENO, buff + t, (N >> 1) - t);
        if (s <= 0) {
            fprintf(stderr, "plot: EOF\n");
            exit(0);
        }
        t += s;
        if (t == (N >> 1)) {
            gBar->draw(buff);
            t = 0;
        }
        return 0;
    }
};

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main(int, char**)
{
    X11::Callback* loop = NULL;

    loop = new LoopCallback;
    gBar = new X11::Bar;
    gBar->run(loop,
              (int (X11::Callback::*)(const X11::Event*))
              & LoopCallback::loop);

    delete gBar;
    delete loop;
    return EXIT_SUCCESS;
}
