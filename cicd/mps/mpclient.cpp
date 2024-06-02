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
    std::cerr << "Usage: " << argv[0] << " <url> [dir]" << std::endl;
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    if (argc <= 1) {
        ::usage(argv);
        return 1;
    }
    std::string url(argv[1]);

    Input input;
    Output output;
    if (argc > 2 && std::filesystem::exists(argv[2])) {
        output.musicDirectory = argv[2];
    }

    gClient = std::unique_ptr<Client>(new Client(input, output, url));

    std::signal(SIGINT, ::signalHandler);

    return gClient->run();
}
