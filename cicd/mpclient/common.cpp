/******************************************************************************!
 * \file common.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <ctime>

/******************************************************************************!
 * \fn nanoSleep
 ******************************************************************************/
void
nanoSleep(long nanoseconds)
{
    struct timespec req = {
        0, nanoseconds
    };

    nanosleep(&req, NULL);
}
