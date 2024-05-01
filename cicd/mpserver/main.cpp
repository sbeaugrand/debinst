/******************************************************************************!
 * \file main.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <filesystem>
#include <fstream>
#include <iostream>
#include "List.h"
#include "Player.h"
#include "Server.h"

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    if (argc <= 1) {
        std::cerr << "Usage: " << argv[0] << " <dir>" << std::endl;
        return 1;
    }
    std::string path(argv[1]);
    List list(path);
    Player player;
    if (int ms = list.readResumeTime(); ms > 0) {
        player.resume(ms);
    }
    jsonrpc::HttpServer httpserver(8383, "", "", 2);  // 2 threads
    Server server(httpserver, list, player);

    server.loop.wait(true);
    return 0;
}
