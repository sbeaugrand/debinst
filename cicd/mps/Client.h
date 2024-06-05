/******************************************************************************!
 * \file Client.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#include <variant>
#include <jsonrpccpp/client.h>
#include <jsonrpccpp/client/connectors/httpclient.h>
#include "Input.h"
#include "Output.h"

/******************************************************************************!
 * \class Client
 ******************************************************************************/
namespace state {
struct Normal {};
struct Album {};
struct Exit {};
}
using State = std::variant<state::Normal,
                           state::Album>;

namespace event {
struct Up {};
struct Down {};
struct Left {};
struct Right {};
struct Ok {};
struct Setup {};
}
using Event = std::variant<event::Up,
                           event::Down,
                           event::Left,
                           event::Right,
                           event::Ok,
                           event::Setup>;

class Client
{
public:
    Client(Input& input, Output& output, const std::string& url);
    ~Client();
    void close();
    int run();
    State onEvent(const state::Normal&, const event::Up&);
    State onEvent(const state::Normal&, const event::Down&);
    State onEvent(const state::Normal&, const event::Left&);
    State onEvent(const state::Normal&, const event::Right&);
    State onEvent(const state::Normal&, const event::Ok&);
    State onEvent(const state::Normal&, const event::Setup&);
    State onEvent(const state::Album&, const event::Up&);
    State onEvent(const state::Album&, const event::Down&);
    State onEvent(const state::Album&, const event::Left&);
    State onEvent(const state::Album&, const event::Right&);
    State onEvent(const state::Album&, const event::Ok&);
    State onEvent(const state::Album&, const event::Setup&);
    void processEvent(const Event& event);

    std::atomic_bool loop = true;
    State state = state::Normal{};
private:
    void currentTitle(const Json::Value json);
    void currentAlbum(const Json::Value json);
    void albumList();

    Input& mInput;
    Output& mOutput;
    jsonrpc::HttpClient mHttpClient;
    jsonrpc::Client mJsonClient;
    std::string::size_type mShift = 0;
    Json::Value mArtist;
    unsigned int mAlbumPos = 0;
    enum {
        EN,
        FR
    } mLang;
};
