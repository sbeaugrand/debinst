/******************************************************************************!
 * \file oscreensaver.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

void displayInit();
void displayQuit();
int displayScreenSaver();

/******************************************************************************!
 * \fn sigTerm
 ******************************************************************************/
void sigTerm(int sig)
{
    if (sig == SIGTERM) {
        displayQuit();
        exit(EXIT_SUCCESS);
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
    if (signal(SIGTERM, sigTerm) == SIG_ERR) {
        return EXIT_FAILURE;
    }

    displayInit();
    for (;;) {
        if (displayScreenSaver() != 0) {
            return EXIT_FAILURE;
        }
        sleep(30);
    }

    return EXIT_SUCCESS;
}
