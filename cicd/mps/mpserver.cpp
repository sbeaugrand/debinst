/******************************************************************************!
 * \file mpserver.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <filesystem>
#include <fstream>
#include <iostream>
#include <argp.h>
#include "List.h"
#include "Player.h"
#include "Server.h"
#include "log.h"

/******************************************************************************!
 * argp
 ******************************************************************************/
const char* argp_program_version =
    "mpserver 1.0.0";
const char* argp_program_bug_address =
    "<sbeaugrand@toto.fr>";
static char doc[] =
    "mpserver -- "
    "C++ music player server with weighted random album selection";
static struct argp_option options[] = {
    { "dir", 'd', "DIR", 0, "music_directory", 0 },
    {}
};
struct arguments
{
    const char* music_directory;
};
static error_t
parse_opt(int key, char* arg, struct argp_state* state)
{
    struct arguments* arguments = static_cast<struct arguments*>(state->input);
    switch (key) {
    case 'd':
        arguments->music_directory = arg;
        DEBUG("music_directory: " << arguments->music_directory);
        break;
    default:
        return ARGP_ERR_UNKNOWN;
    }
    return 0;
}
static struct argp argp = { options, parse_opt, 0, doc, 0, 0, 0 };

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    struct arguments arguments = {};
    ::setenv("ARGP_HELP_FMT", "no-dup-args-note", 0);
    ::argp_parse(&argp, argc, argv, 0, 0, &arguments);

    Player player;
    player.init();
    if (player.musicDirectory.empty()) {
        if (arguments.music_directory) {
            DEBUG("music_directory from argv");
            player.musicDirectory = arguments.music_directory;
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
