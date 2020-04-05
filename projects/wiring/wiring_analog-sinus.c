/******************************************************************************!
 * \file wiring_analog-sinus.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <sys/time.h>
#include <math.h>
#include <stdint.h>
#include "debug.h"

extern struct timespec gTimeval;
extern struct timespec gOffset;

int gArgc;
char** gArgv;

/******************************************************************************!
 * \fn analogSetFrequencies
 ******************************************************************************/
void analogSetFrequencies(int argc, char* argv[])
{
    if (argc < 3) {
        ERROR("Usage: %s <valeurs-par-seconde> <frequence> [frequence]...",
              argv[0]);
        exit(EXIT_FAILURE);
    }
    gArgc = argc - 1;
    gArgv = argv + 1;
}

/******************************************************************************!
 * \fn analogInit
 ******************************************************************************/
int analogInit()
{
    return 1;
}

/******************************************************************************!
 * \fn analogRead
 ******************************************************************************/
int analogRead(__attribute__((__unused__)) uint8_t pin)
{
    static double val;
    static int i;

    val = 0;
    for (i = 1; i < gArgc; ++i) {
        val += sin(2 * M_PI * atoi(gArgv[i]) *
                   (gTimeval.tv_sec - gOffset.tv_sec +
                    (double) gTimeval.tv_nsec / 1000000000L));
    }
    //val = fabs(val) * 2.0 - 1.0;  // Sinus redresse'
    return (uint16_t) ((val * (511.0 / (gArgc - 1))) + 511.0);
}

/******************************************************************************!
 * \fn analogQuit
 ******************************************************************************/
void analogQuit()
{
}
