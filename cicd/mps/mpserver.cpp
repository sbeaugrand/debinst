/******************************************************************************!
 * \file mpserver.cpp
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
#include "log.h"

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    Player player;
    player.init();
    if (player.musicDirectory.empty()) {
        if (argc > 1) {
            DEBUG("music_directory from argv");
            player.musicDirectory = argv[1];
        } else {
            ERROR("no music_directory");
            return 1;
        }
    }

    List list(player.musicDirectory);
    player.resume(list.readResumeTime());

    jsonrpc::HttpServer httpserver(8383, "", "", 2);  // 2 threads
    Server server(httpserver, list, player);

    server.loop.wait(true);
    server.stop();
    return 0;
}
