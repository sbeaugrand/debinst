/******************************************************************************!
 * \file main.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include "Input.h"
#include "Output.h"
#include "Client.h"

Input gInput;

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    if (argc <= 2) {
        std::cerr << "Usage: " << argv[0] << " <dir> <url>" << std::endl;
        return 1;
    }
    std::string path(argv[1]);
    std::string url(argv[2]);

    Output output(path);

    Client client(gInput, output, url);
    return client.run();
}
