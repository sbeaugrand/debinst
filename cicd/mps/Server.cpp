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
    return mPlayer.currentTitle();
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
    auto pos4 = mSelect.rfind('/');
    auto pos1 = mSelect.rfind('/', pos4 - 1) + 1;
    auto pos2 = mSelect.find(" - ", pos1);
    auto pos3 = mSelect.find(" - ", pos2 + 3) + 3;
    Json::Value result;
    result["artist"] = mSelect.substr(pos1, pos2 - pos1);
    result["album"] = mSelect.substr(pos3, pos4 - pos3);
    result["date"] = mSelect.substr(pos2 + 3, pos3 - pos2 - 6);
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
    if (! mSelect.empty()) {
        const auto now = std::chrono::steady_clock::now();
        const std::chrono::duration<double> diff = now - mSelectTime;
        if (diff.count() < 20) {
            mPlayer.m3u(mSelect);
            mList.writeLog(mSelect);
            mSelect.clear();
            return mPlayer.currentTitle();
        }
        mSelect.clear();
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
    return mPlayer.currentTitle();
}

/******************************************************************************!
 * \fn pause
 ******************************************************************************/
Json::Value
Server::pause()
{
    DEBUG("");
    mPlayer.pause();
    return mPlayer.currentTitle();
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
    return mPlayer.currentTitle();
}

/******************************************************************************!
 * \fn next
 ******************************************************************************/
Json::Value
Server::next()
{
    DEBUG("");
    mPlayer.startRel(1);
    return mPlayer.currentTitle();
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
    auto path = mList.album(artist, pos);
    mPlayer.m3u(path);
    mList.writeLog(path);
    return mPlayer.currentTitle();
}

/******************************************************************************!
 * \fn pos
 ******************************************************************************/
Json::Value
Server::pos(int pos)
{
    DEBUG("");
    mPlayer.startId(pos);
    return mPlayer.currentTitle();
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
