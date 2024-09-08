/******************************************************************************!
 * \file mpclient.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <filesystem>
#include <iostream>
#include <csignal>
#include <argp.h>
#include "Input.h"
#include "Output.h"
#include "Client.h"
#include "log.h"

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
 * argp
 ******************************************************************************/
const char *argp_program_version =
    "mpclient 1.0.0";
const char *argp_program_bug_address =
    "<sbeaugrand@toto.fr>";
static char doc[] =
    "mpclient -- "
    "C++ music player client with weighted random album selection";
static struct argp_option options[] = {
    { "dir", 'd', "DIR", 0, "music_directory", 0 },
    { 0, 0, 0, 0, 0, 0 }
};
struct arguments
{
    const char* server_url;
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
    case ARGP_KEY_ARG:
        arguments->server_url = arg;
        break;
    case ARGP_KEY_END:
        if (! arguments->server_url) {
            argp_usage(state);
        }
        break;
    default:
        return ARGP_ERR_UNKNOWN;
    }
    return 0;
}
static struct argp argp = { options, parse_opt, "SERVER", doc, 0, 0, 0 };

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    struct arguments arguments = { 0, 0 };
    argp_parse(&argp, argc, argv, 0, 0, &arguments);

    std::string url(arguments.server_url);

    Input input;
    Output output;
    if (arguments.music_directory &&
        std::filesystem::exists(arguments.music_directory)) {
        output.musicDirectory = arguments.music_directory;
    }

    gClient = std::unique_ptr<Client>(new Client(input, output, url));

    std::signal(SIGINT, ::signalHandler);

    return gClient->run();
}
