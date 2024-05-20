/******************************************************************************!
 * \file Client.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "Client.h"
#include "log.h"

/******************************************************************************!
 * \fn Client
 ******************************************************************************/
Client::Client(Input& input, Output& output, const std::string& url)
    : mInput(input)
    , mOutput(output)
    , mHttpClient(url)
    , mJsonClient(mHttpClient)
{
}

/******************************************************************************!
 * \fn Client
 ******************************************************************************/
Client::~Client()
{
}

/******************************************************************************!
 * \fn onEvent
 ******************************************************************************/
State
Client::onEvent(state::Normal state, const event::Up&)
{
    return state;
}

State
Client::onEvent(state::Normal state, const event::Down&)
{
    return state;
}

State
Client::onEvent(state::Normal /*state*/, const event::Left&)
{
    return state::Album{};
}

State
Client::onEvent(state::Normal state, const event::Right&)
{
    // Hour
    return state;
}

State
Client::onEvent(state::Normal state, const event::Ok&)
{
    try {
        Json::Value params;
        Json::Value result = mJsonClient.CallMethod("ok", params);
        mOutput.write(result["pause"].asBool() ? "PAUSE" : "PLAY", "");
    } catch (jsonrpc::JsonRpcException &e) {
        ERROR(e.what());
    }
    return state;
}

State
Client::onEvent(state::Normal state, const event::Setup&)
{
    try {
        Json::Value params;
        Json::Value result = mJsonClient.CallMethod("rand", params);
        auto path = result["album"].asString();
        auto pos1 = path.rfind(" - ");
        auto pos2 = path.rfind('/');
        auto pos3 = path.rfind(" - ", pos1 - 1);
        auto pos4 = path.rfind("/", pos3 - 1);
        auto artist = path.substr(pos4 + 1, pos3 - pos4 - 1);
        auto album = path.substr(pos1 + 3, pos2 - pos1 - 3);
        mOutput.write(artist.c_str(), album.c_str());
    } catch (jsonrpc::JsonRpcException &e) {
        ERROR(e.what());
    }
    return state;
}

State
Client::onEvent(state::Album state, const event::Up&)
{
    // Todo
    return state;
}

State
Client::onEvent(state::Album state, const event::Down&)
{
    // Todo
    return state;
}

State
Client::onEvent(state::Album /*state*/, const event::Left&)
{
    // Todo
    return state::Album{};
}

State
Client::onEvent(state::Album /*state*/, const event::Right&)
{
    return state;
}

State
Client::onEvent(state::Album  /*state*/, const event::Ok&)
{
    return state::Normal{};
}

State
Client::onEvent(state::Album state, const event::Setup&)
{
    return state;
}

/******************************************************************************!
 * \fn processEvent
 ******************************************************************************/
void Client::processEvent(const Event& event)
{
    state = std::visit(
        [this](const auto& st, const auto& ev) { return onEvent(st, ev); },
        state, event);
}

/******************************************************************************!
 * \fn run
 ******************************************************************************/
int Client::run()
{
    for (;;) {
        mInput.hasEvent.wait(false);
        auto key = mInput.key;
        switch (key) {
        case Input::KEY_UP:
            this->processEvent(event::Up{});
            break;
        case Input::KEY_DOWN:
            this->processEvent(event::Down{});
            break;
        case Input::KEY_LEFT:
            this->processEvent(event::Left{});
            break;
        case Input::KEY_RIGHT:
            this->processEvent(event::Right{});
            break;
        case Input::KEY_OK:
            this->processEvent(event::Ok{});
            break;
        case Input::KEY_SETUP:
            this->processEvent(event::Setup{});
            break;
        case Input::KEY_BACK:
            break;
        case Input::KEY_MODE:
            break;
        case Input::KEY_PLAYPAUSE:
            break;
        case Input::KEY_UNDEFINED:
            break;
        }
    }

    return 0;
}
