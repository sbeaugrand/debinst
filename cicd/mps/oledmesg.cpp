/******************************************************************************!
 * \file oledmesg.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <argp.h>
#include "upm/ssd1306.hpp"
#include "log.h"

#define DEVICE_ADDRESS 0x3C

/******************************************************************************!
 * argp
 ******************************************************************************/
const char *argp_program_version =
    "oledmesg 1.0.0";
const char *argp_program_bug_address =
    "<sbeaugrand@toto.fr>";
static char doc[] =
    "oledmesg -- "
    "mps oledmesg";
static struct argp_option options[] = {
    { "message", 'm', "STRING", 0, 0, 0 },
    { "x", 'x', "NUM", 0, 0, 0 },
    { "y", 'y', "NUM", 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0 }
};
struct arguments
{
    const char* message;
    const char* x;
    const char* y;
};
static error_t
parse_opt(int key, char* arg, struct argp_state* state)
{
    struct arguments* arguments = static_cast<struct arguments*>(state->input);
    switch (key) {
    case 'm':
        arguments->message = arg;
        DEBUG("message: " << arguments->message);
        break;
    case 'x':
        arguments->x = arg;
        DEBUG("x: " << arguments->x);
        break;
    case 'y':
        arguments->y = arg;
        DEBUG("y: " << arguments->y);
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
    struct arguments arguments = { 0, 0, 0 };
    argp_parse(&argp, argc, argv, 0, 0, &arguments);

    upm::SSD1306* oled;
    try {
        oled = new upm::SSD1306(0, DEVICE_ADDRESS);
    } catch (...) {
        oled = new upm::SSD1306(1, DEVICE_ADDRESS);
    }
    oled->clear();

    if (! arguments.message) {
        return 0;
    }

    int x = (arguments.x) ? atoi(arguments.x) : 0;
    int y = (arguments.y) ? atoi(arguments.y) : 0;
    oled->dim(true);
    oled->setCursor(y, x);
    oled->write(arguments.message);
    return 0;
}
