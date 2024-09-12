/******************************************************************************!
 * \file mpssaver.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <filesystem>
#include <variant>
#include <csignal>
#include <stdlib.h>
#include <argp.h>
#include "Input.h"
#include "Output.h"
#include "log.h"

bool gLoop = true;
std::unique_ptr<Input> gInput;
std::unique_ptr<Output> gOutput;

/******************************************************************************!
 * \fn signalHandler
 ******************************************************************************/
void
signalHandler(int signal)
{
    if (signal == SIGINT) {
        gLoop = false;
        gInput->hasEvent = true;
        gInput->hasEvent.notify_one();
    }
}

/******************************************************************************!
 * \namespace state
 ******************************************************************************/
namespace state {
struct Normal {};
struct Menu {};
struct Date {};
struct Hour {};
}
using State = std::variant<state::Normal,
                           state::Menu,
                           state::Date,
                           state::Hour>;

/******************************************************************************!
 * \namespace event
 ******************************************************************************/
namespace event {
struct Up {};
struct Down {};
struct Left {};
struct Right {};
struct Ok {};
}
using Event = std::variant<event::Up,
                           event::Down,
                           event::Left,
                           event::Right,
                           event::Ok>;

/******************************************************************************!
 * \fn drawDate
 ******************************************************************************/
State
drawDate(int isDay)
{
    char line1[6];
    char line2[6];
    time_t tOfTheDay;
    struct tm* tmOfTheDay;

    tOfTheDay = ::time(NULL);
    tmOfTheDay = ::localtime(&tOfTheDay);

    if (isDay) {
        ::strftime(line1, sizeof(line1), "%dX%m", tmOfTheDay);
        *line2 = '\0';
    } else {
        ::strftime(line2, sizeof(line2), "%H:%M", tmOfTheDay);
        *line1 = '\0';
    }
    gOutput->write("", line1, line2, "");

    if (isDay) {
        return state::Date{};
    } else {
        return state::Hour{};
    }
}

/******************************************************************************!
 * \class Machine
 ******************************************************************************/
State
onEvent(const state::Normal& state, const event::Up&) {
    return state;
}
State
onEvent(const state::Normal& state, const event::Down&) {
    return state;
}
State
onEvent(const state::Normal& state, const event::Left&) {
    return state;
}
State
onEvent(const state::Normal& state, const event::Right&) {
    return state;
}
State
onEvent(const state::Normal&, const event::Ok&) {
    gOutput->write("",
                   "     reboot",
                   "date cancel rtc",
                   "      halt");
    return state::Menu{};
}

State
onEvent(const state::Menu&, const event::Up&) {
    if (::system("sudo /sbin/reboot") == 0) {
        gOutput->write("", "reboot", "", "");
    }
    return state::Normal{};
}
State
onEvent(const state::Menu&, const event::Down&) {
    if (::system("sudo /sbin/halt") == 0) {
        gOutput->write("", "halt", "", "");
    }
    return state::Normal{};
}
State
onEvent(const state::Menu&, const event::Left&) {
    return drawDate(1);
}
State
onEvent(const state::Menu&, const event::Right&) {
    if (::system("sudo /usr/sbin/rtc") == 0) {
    }
    gOutput->screensaver();
    return state::Normal{};
}
State
onEvent(const state::Menu&, const event::Ok&) {
    gOutput->screensaver();
    return state::Normal{};
}

State
onEvent(const state::Date&, const event::Up&) {
    if (::system("sudo /usr/sbin/rtc `date --date='+1 month' +%FT%Tw%w`;"
                 " sudo /usr/sbin/rtc") == 0) {
    }
    return drawDate(1);
}
State
onEvent(const state::Date&, const event::Down&) {
    if (::system("sudo /usr/sbin/rtc `date --date='-1 month' +%FT%Tw%w`;"
                 " sudo /usr/sbin/rtc") == 0) {
    }
    return drawDate(1);
}
State
onEvent(const state::Date&, const event::Left&) {
    if (::system("sudo /usr/sbin/rtc `date --date='-1 day' +%FT%Tw%w`;"
                 " sudo /usr/sbin/rtc") == 0) {
    }
    return drawDate(1);
}
State
onEvent(const state::Date&, const event::Right&) {
    if (::system("sudo /usr/sbin/rtc `date --date='+1 day' +%FT%Tw%w`;"
                 " sudo /usr/sbin/rtc") == 0) {
    }
    return drawDate(1);
}
State
onEvent(const state::Date&, const event::Ok&) {
    return drawDate(0);
}

State
onEvent(const state::Hour&, const event::Up&) {
    if (::system("sudo /usr/sbin/rtc `date --date='+1 hour' +%FT%Tw%w`;"
                 " sudo /usr/sbin/rtc") == 0) {
    }
    return drawDate(0);
}
State
onEvent(const state::Hour&, const event::Down&) {
    if (::system("sudo /usr/sbin/rtc `date --date='-1 hour' +%FT%Tw%w`;"
                 " sudo /usr/sbin/rtc") == 0) {
    }
    return drawDate(0);
}
State
onEvent(const state::Hour&, const event::Left&) {
    if (::system("sudo /usr/sbin/rtc `date --date='-1 min' +%FT%Tw%w`;"
                 " sudo /usr/sbin/rtc") == 0) {
    }
    return drawDate(0);
}
State
onEvent(const state::Hour&, const event::Right&) {
    if (::system("sudo /usr/sbin/rtc `date --date='+1 min' +%FT%Tw%w`;"
                 " sudo /usr/sbin/rtc") == 0) {
    }
    return drawDate(0);
}
State
onEvent(const state::Hour&, const event::Ok&) {
    gOutput->screensaver();
    return state::Normal{};
}

class Machine
{
public:
    ~Machine() {
        std::cout << "Machine::dtor" << std::endl;
    }
    void processEvent(const Event& event) {
        state = std::visit(
            [](const auto& st, const auto& ev) { return onEvent(st, ev); },
            state, event);
    }
    State state = state::Normal{};
};

/******************************************************************************!
 * argp
 ******************************************************************************/
const char *argp_program_version =
    "mpssaver 1.0.0";
const char *argp_program_bug_address =
    "<sbeaugrand@toto.fr>";
static char doc[] =
    "mpssaver -- "
    "mps screensaver";
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
    argp_parse(&argp, argc, argv, 0, 0, &arguments);

    gInput = std::unique_ptr<Input>(new Input);
    gOutput = std::unique_ptr<Output>(new Output);

    Machine machine;
    if (arguments.music_directory) {
        gOutput->musicDirectory = arguments.music_directory;
    }
    gOutput->screensaver();

    std::signal(SIGINT, ::signalHandler);

    while (gLoop) {
        gInput->hasEvent.wait(false);
        if (! gLoop) {
            return 0;
        }
        auto key = gInput->key;
        gInput->hasEvent = false;
        switch (key) {
        case Input::KEY_UP:
            machine.processEvent(event::Up{});
            break;
        case Input::KEY_DOWN:
            machine.processEvent(event::Down{});
            break;
        case Input::KEY_LEFT:
            machine.processEvent(event::Left{});
            break;
        case Input::KEY_RIGHT:
            machine.processEvent(event::Right{});
            break;
        case Input::KEY_OK:
            machine.processEvent(event::Ok{});
            break;
        case Input::KEY_SETUP:
        case Input::KEY_BACK:
        case Input::KEY_UNDEFINED:
            break;
        }
    }

    return 0;
}
