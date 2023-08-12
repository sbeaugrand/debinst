/******************************************************************************!
 * \file main.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "Server.h"

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    int port = 8080;;
    if (argc == 2) {
        port = atoi(argv[1]);
    }

    Server::instance().open(port);

    return 0;
}
