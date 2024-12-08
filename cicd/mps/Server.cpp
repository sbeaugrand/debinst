/******************************************************************************!
 * \file Server.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <chrono>
#include <iostream>
#include <filesystem>
#include <algorithm>
#include "Server.h"
#include "List.h"
#include "Player.h"
#include "path.h"
#include "log.h"

/******************************************************************************!
 * \fn Server
 ******************************************************************************/
Server::Server(jsonrpc::AbstractServerConnector& conn,
               List& list,
               Player& player)
    : AbstractStubServer(conn, jsonrpc::JSONRPC_SERVER_V1V2)
    , mList(list)
    , mPlayer(player)
{
    this->StartListening();
}

/******************************************************************************!
 * \fn ~Server
 ******************************************************************************/
Server::~Server()
{
    DEBUG("");
    this->StopListening();
}

/******************************************************************************!
 * \fn list
 ******************************************************************************/
Json::Value
Server::list()
{
    DEBUG("");
    Json::Value result = mPlayer.titleList();
    return result;
}

/******************************************************************************!
 * \fn info
 ******************************************************************************/
Json::Value
Server::info()
{
    DEBUG("");
    Json::Value result = mPlayer.currentTitle();
    result["abrev"] = mAbrev;
    return result;
}

/******************************************************************************!
 * \fn rand
 ******************************************************************************/
Json::Value
Server::rand()
{
    DEBUG("");
    const auto [path, abrev, days] = mList.rand();
    mSelect = path;
    mSelectTime = std::chrono::steady_clock::now();
    mAbrev = abrev;
    const auto [arti, date, albu] = ::splitPath(path);
    Json::Value result;
    result["artist"] = arti;
    result["date"] = date;
    result["album"] = albu;
    result["abrev"] = abrev;
    result["days"] = days;
    return result;
}

/******************************************************************************!
 * \fn ok
 ******************************************************************************/
Json::Value
Server::ok()
{
    DEBUG("");
    if (! mSelect.empty() && mSelectTime !=
        std::chrono::time_point<std::chrono::steady_clock>::min()) {
        const auto now = std::chrono::steady_clock::now();
        const std::chrono::duration<double> diff = now - mSelectTime;
        if (diff.count() < 20) {
            mPlayer.m3u(mSelect);
            mList.writeLog(mSelect);
            mSelectTime =
                std::chrono::time_point<std::chrono::steady_clock>::min();
            Json::Value json = mPlayer.currentTitle();
            json["cs"] = -1;
            return json;
        } else {
            mAbrev.clear();
            mSelectTime =
                std::chrono::time_point<std::chrono::steady_clock>::min();
        }
    }
    return this->pause();
}

/******************************************************************************!
 * \fn play
 ******************************************************************************/
Json::Value
Server::play()
{
    DEBUG("");
    mPlayer.start();
    Json::Value result = mPlayer.currentTitle();
    result["abrev"] = mAbrev;
    return result;
}

/******************************************************************************!
 * \fn pause
 ******************************************************************************/
Json::Value
Server::pause()
{
    DEBUG("");
    mPlayer.pause();
    Json::Value result = mPlayer.currentTitle();
    result["abrev"] = mAbrev;
    return result;
}

/******************************************************************************!
 * \fn stop
 ******************************************************************************/
Json::Value
Server::stop()
{
    DEBUG("");
    auto ms = mPlayer.getPlaytime();
    mList.writeResumeTime(ms);
    mPlayer.stop();
    Json::Value result;
    result["result"] = "ok";
    return result;
}

/******************************************************************************!
 * \fn prev
 ******************************************************************************/
Json::Value
Server::prev()
{
    DEBUG("");
    mPlayer.startRel(-1);
    Json::Value result = mPlayer.currentTitle();
    result["abrev"] = mAbrev;
    return result;
}

/******************************************************************************!
 * \fn next
 ******************************************************************************/
Json::Value
Server::next()
{
    DEBUG("");
    mPlayer.startRel(1);
    Json::Value result = mPlayer.currentTitle();
    result["abrev"] = mAbrev;
    return result;
}

/******************************************************************************!
 * \fn artist
 ******************************************************************************/
Json::Value
Server::artist()
{
    DEBUG("");
    Json::Value json = mPlayer.currentTitle();
    return mList.artist(json["artist"].asString(),
                        json["album"].asString());
}

/******************************************************************************!
 * \fn album
 ******************************************************************************/
Json::Value
Server::album(const std::string& artist, int pos)
{
    DEBUG("");
    const auto [path, abrev] = mList.album(artist, pos);
    if (! path.empty()) {
        mPlayer.m3u(path);
        mSelect = path;
        mSelectTime =
            std::chrono::time_point<std::chrono::steady_clock>::min();
        mAbrev = abrev;
        mList.writeLog(path);
    }
    Json::Value result = mPlayer.currentTitle();
    if (path.empty()) {
        result["abrev"] = mAbrev;
    } else if (pos != -1) {
        result["cs"] = -1;
    }
    return result;
}

/******************************************************************************!
 * \fn pos
 ******************************************************************************/
Json::Value
Server::pos(int pos)
{
    DEBUG("");
    mPlayer.startId(pos);
    Json::Value result = mPlayer.currentTitle();
    result["abrev"] = mAbrev;
    return result;
}

/******************************************************************************!
 * \fn dir
 ******************************************************************************/
Json::Value
Server::dir(const std::string& path)
{
    auto p = path;
    std::ranges::replace(p, '+', ' ');
    DEBUG(p);
    if (std::filesystem::exists(mPlayer.musicDirectory + '/' +
                                p + "/00.m3u")) {
        mPlayer.m3u(p + "/00.m3u");
        mList.writeLog(p + "/00.m3u");
        return Json::Value{};
    } else {
        return mList.dir(p);
    }
}

/******************************************************************************!
 * \fn quit
 ******************************************************************************/
void
Server::quit()
{
    DEBUG("");
    this->loop = false;
    loop.notify_one();
}

/******************************************************************************!
 * \fn musicDirectory
 ******************************************************************************/
std::string
Server::musicDirectory()
{
    return mPlayer.musicDirectory;
}

/******************************************************************************!
 * \fn checksum
 ******************************************************************************/
Json::Value
Server::checksum()
{
    DEBUG("");
    int cs = 0;
    std::string path =
        mPlayer.musicDirectory + '/' +
        mSelect.substr(0, mSelect.rfind('/') + 1);

    if (std::filesystem::exists(path + ".sha")) {
        auto cmd = std::string("cd \"") + path +
            "\"; /usr/bin/sha1sum -c .sha >/dev/null";
        if (::system(cmd.c_str()) != 0) {
            cs = 1;
            ERROR(cs);
        }
    } else {
        auto cmd = std::string("cd \"") + path +
            "\"; /usr/bin/sha1sum * >.sha";
        if (::system(cmd.c_str()) != 0) {
            cs = 2;
            ERROR(cs);
        }
    }

    Json::Value json = mPlayer.currentTitle();
    if (cs) {
        json["cs"] = cs;
    } else {
        json["abrev"] = mAbrev;
    }
    return json;
}
