/******************************************************************************!
 * \file mpclient.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <filesystem>
#include <iostream>
#include <csignal>
#include "Input.h"
#include "Output.h"
#include "Client.h"

std::unique_ptr<Client> gClient;

/******************************************************************************!
 * \fn signalHandler
 ******************************************************************************/
void
signalHandler(int signal)
{
    if (signal == SIGINT && gClient) {
        gClient->close();
    }
}

/******************************************************************************!
 * \fn usage
 ******************************************************************************/
void
usage(char** argv)
{
    std::cerr << "Usage: " << argv[0] << " <dir>" << std::endl;
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    if (argc <= 2) {
        ::usage(argv);
        return 1;
    }
    std::string path(argv[1]);
    std::string url(argv[2]);
    if (! std::filesystem::exists(path)) {
        ::usage(argv);
        return 2;
    }

    Input input;
    Output output(path);
    gClient = std::unique_ptr<Client>(new Client(input, output, url));

    std::signal(SIGINT, ::signalHandler);

    return gClient->run();
}
