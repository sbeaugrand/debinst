/******************************************************************************!
 * \file oscreensaver.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <time.h>
#include "common.h"

void displayInit();
void displayQuit();
void displayWrite(const char* line1, const char* line2);
int displayScreenSaver();
void keypadInit();
void keypadRead();
void keypadQuit();
int undefinedButton();
int rightButton();
int setupTime();
int setupDate();

/******************************************************************************!
 * \fn drawDate
 ******************************************************************************/
int drawDate(int isDay)
{
    char line1[6];
    char line2[6];
    time_t tOfTheDay;
    struct tm* tmOfTheDay;

    tOfTheDay = time(NULL);
    tmOfTheDay = localtime(&tOfTheDay);

    if (isDay) {
        strftime(line1, sizeof(line1), "%dX%m", tmOfTheDay);
        *line2 = '\0';
    } else {
        strftime(line2, sizeof(line2), "%H:%M", tmOfTheDay);
        *line1 = '\0';
    }
    displayWrite(line1, line2);

    return 1;
}

/******************************************************************************!
 * \fn sigTerm
 ******************************************************************************/
void sigTerm(int sig)
{
    if (sig == SIGTERM) {
        keypadQuit();
        displayQuit();
        exit(EXIT_SUCCESS);
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
    enum {
        STATE0_NORM,
        STATE4_HOUR,
        STATE5_DATE
    } state = STATE0_NORM;

    int pass;
    int i;

    if (signal(SIGTERM, sigTerm) == SIG_ERR) {
        return EXIT_FAILURE;
    }

    displayInit();
    keypadInit();
    for (;;) {
        if (state == STATE0_NORM) {
            if (displayScreenSaver() != 0) {
                return EXIT_FAILURE;
            }
        }
        pass = 0;
        for (i = 0; i < 200; ++i) {
            keypadRead();
            nanoSleep(100000000);
            if (! undefinedButton()) {
                pass = 1;
            }
            /*  */ if (state == STATE0_NORM && rightButton()) {
                state = STATE4_HOUR;
                drawDate(0);
            } else if (state == STATE4_HOUR && setupTime()) {
                state = STATE5_DATE;
                drawDate(1);
            } else if (state == STATE5_DATE && setupDate()) {
                state = STATE0_NORM;
                break;
            }
        }
        if (pass == 0) {
            state = STATE0_NORM;
        }
    }

    return EXIT_SUCCESS;
}
