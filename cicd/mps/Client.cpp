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
    if (std::string(std::getenv("LANG")).starts_with("fr")) {
        mLang = FR;
    } else {
        mLang = EN;
    }
}

/******************************************************************************!
 * \fn Client
 ******************************************************************************/
Client::~Client()
{
    DEBUG("");
}

/******************************************************************************!
 * \fn close
 ******************************************************************************/
void
Client::close()
{
    this->loop = false;
    mInput.hasEvent = true;
    mInput.hasEvent.notify_one();
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
        auto pos = result.get("pos", -1).asInt() + 1;
        auto length = result.get("length", -1).asInt() + 1;
        auto title = result.get("title", error).asString();
        auto album = result.get("album", error).asString();
        auto artist = result.get("artist", error).asString();
        auto date = result.get("date", error).asString();
        int diffmax = -Output::LCD_SHIFT;
        if (mShift > 0) {
            auto size = album.size();
            int diff = size - mShift - Output::LCD_COLS;
            if (diff >= 0) {
                album = album.substr(mShift);
            } else if (size > Output::LCD_COLS) {
                album = album.substr(size - Output::LCD_COLS);
            }
            if (diffmax < diff) {
                diffmax = diff;
            }
        }
        if (mShift > 0) {
            auto size = title.size();
            int diff = size - mShift - Output::LCD_COLS;
            if (diff >= 0) {
                title = title.substr(mShift);
            } else if (size > Output::LCD_COLS) {
                title = title.substr(size - Output::LCD_COLS);
            }
            if (diffmax < diff) {
                diffmax = diff;
            }
        }
        if (mShift > 0 && diffmax <= -Output::LCD_SHIFT) {
            mShift -= Output::LCD_SHIFT;
        }
        mOutput.write((pause ? "PAUSE " : "") + artist,
                      album,
                      date + ' ' +
                      std::to_string(pos) + '/' + std::to_string(length),
                      title);
    } catch (jsonrpc::JsonRpcException& e) {
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
    try {
        Json::Value params;
        Json::Value result = mJsonClient.CallMethod("artist", params);
        Json::Value empty("");
        auto line1 = result.get("artist", empty).asString();
        auto line2 = result["album"].get(Json::ArrayIndex(0), empty).asString();
        auto line3 = result["album"].get(Json::ArrayIndex(1), empty).asString();
        auto line4 = result["album"].get(Json::ArrayIndex(2), empty).asString();
        mOutput.write(line1,
                      line2,
                      line3,
                      line4);
    } catch (jsonrpc::JsonRpcException& e) {
        ERROR(e.what());
    }
    return state::Album{};
}
State
Client::onEvent(const state::Normal& state, const event::Right&)
{
    this->currentTitle("info");
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
                        dateR[1] = (mLang == FR) ? 'A' : 'Y';
                    } else {
                        dateR[1] = 'M';
                    }
                } else {
                    dateR[1] = (mLang == FR) ? 'S' : 'W';
                }
            } else {
                dateR[1] = (mLang == FR) ? 'J' : 'D';
            }
            dateR[0] = '0' + d;
        }
        mOutput.write(result["artist"].asString(),
                      result["album"].asString(),
                      result["date"].asString(),
                      result["abrev"].asString() + ' ' + dateR);
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
    mShift = 0;
    this->currentTitle("info");
    return state::Normal{};
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
void
Client::processEvent(const Event& event)
{
    state = std::visit(
        [this](const auto& st, const auto& ev) {
        return onEvent(st, ev);
    },
        state, event);
}

/******************************************************************************!
 * \fn run
 ******************************************************************************/
int
Client::run()
{
    this->currentTitle("info");
    while (this->loop) {
        mInput.hasEvent.wait(false);
        if (! this->loop) {
            return 0;
        }
        auto key = mInput.key;
        mInput.hasEvent = false;
        switch (key) {
        case Input::KEY_UP:
            mShift = 0;
            this->processEvent(event::Up{});
            break;
        case Input::KEY_DOWN:
            mShift = 0;
            this->processEvent(event::Down{});
            break;
        case Input::KEY_LEFT:
            if (mShift > 0) {
                mShift -= Output::LCD_SHIFT;
                this->processEvent(event::Right{});
            } else {
                mShift = 0;
                this->processEvent(event::Left{});
            }
            break;
        case Input::KEY_RIGHT:
            mShift += Output::LCD_SHIFT;
            this->processEvent(event::Right{});
            break;
        case Input::KEY_OK:
            mShift = 0;
            this->processEvent(event::Ok{});
            break;
        case Input::KEY_SETUP:
            mShift = 0;
            this->processEvent(event::Setup{});
            break;
        case Input::KEY_BACK:
            mShift = 0;
            this->currentTitle("info");
            break;
        case Input::KEY_UNDEFINED:
            break;
        }
    }
    return 0;
}
