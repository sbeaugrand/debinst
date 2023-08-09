/******************************************************************************!
 * \file client.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include <httplib.h>

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    if (argc != 4) {
        return 1;
    }
    const char* host = argv[1];
    int port = atoi(argv[2]);
    const char* resource = argv[3];

    httplib::Client cli(host, port);

    if (auto res = cli.Get(resource)) {
        std::cout << res->body;
    } else {
        std::cout << "error code: " << res.error() << std::endl;
    }

    return 0;
}
