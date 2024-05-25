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
 * \fn currentTitle
 ******************************************************************************/
void
Client::currentTitle(const char* method)
{
    try {
        Json::Value params;
        Json::Value result = mJsonClient.CallMethod(method, params);
        Json::Value error("error");
        auto pause = result.get("pause", false).asBool();
        auto pos = result.get("pos", -1).asInt();
        auto title = result.get("title", error).asString();
        auto album = result.get("album", error).asString();
        auto artist = result.get("artist", error).asString();
        mOutput.write((pause ? "PAUSE " : "") + artist,
                      album,
                      std::to_string(pos),
                      title);
    } catch (jsonrpc::JsonRpcException &e) {
        ERROR(e.what());
    }
}

/******************************************************************************!
 * \fn onEvent
 ******************************************************************************/
State
Client::onEvent(const state::Normal& state, const event::Up&)
{
    this->currentTitle("prev");
    return state;
}
State
Client::onEvent(const state::Normal& state, const event::Down&)
{
    this->currentTitle("next");
    return state;
}
State
Client::onEvent(const state::Normal&, const event::Left&)
{
    return state::Album{};
}
State
Client::onEvent(const state::Normal& state, const event::Right&)
{
    // Hour
    return state;
}
State
Client::onEvent(const state::Normal& state, const event::Ok&)
{
    this->currentTitle("ok");
    return state;
}
State
Client::onEvent(const state::Normal& state, const event::Setup&)
{
    try {
        Json::Value params;
        Json::Value result = mJsonClient.CallMethod("rand", params);
        char dateR[3] = { 0 };
        if (int d = result["days"].asInt(); d > 0) {
            int dInit = d;
            if (d > 9) {
                d /= 7;
                if (d > 9) {
                    d = dInit / 31;
                    if (d > 9) {
                        d /= 12;
                        dateR[1] = 'Y';
                    } else {
                        dateR[1] = 'M';
                    }
                } else {
                    dateR[1] = 'W';
                }
            } else {
                dateR[1] = 'D';
            }
            dateR[0] = '0' + d;
        }
        mOutput.write(result["artist"].asString(),
                      result["album"].asString(),
                      result["abrev"].asString(),
                      dateR);
    } catch (jsonrpc::JsonRpcException& e) {
        ERROR(e.what());
    }
    return state;
}

State
Client::onEvent(const state::Album& state, const event::Up&)
{
    // Todo
    return state;
}
State
Client::onEvent(const state::Album& state, const event::Down&)
{
    // Todo
    return state;
}
State
Client::onEvent(const state::Album&, const event::Left&)
{
    // Todo
    return state::Album{};
}
State
Client::onEvent(const state::Album&, const event::Right&)
{
    return state;
}
State
Client::onEvent(const state::Album&, const event::Ok&)
{
    return state::Normal{};
}
State
Client::onEvent(const state::Album& state, const event::Setup&)
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
