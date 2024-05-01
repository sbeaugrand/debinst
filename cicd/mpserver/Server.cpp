/******************************************************************************!
 * \file Server.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
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
    mPlayer.init();
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
 * \fn rand
 ******************************************************************************/
Json::Value
Server::rand()
{
    DEBUG("");
    mSelect = std::string("file:///data/mp3/") + mList.rand();
    Json::Value result;
    result["album"] = mSelect;
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
        mPlayer.m3u(mSelect.c_str());
    }
    return mPlayer.currentTitle();
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
    mPlayer.stop();
    auto ms = mPlayer.getPlaytime();
    mList.writeResumeTime(ms);
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
 * \fn quit
 ******************************************************************************/
void
Server::quit()
{
    DEBUG("");
    this->loop = false;
    loop.notify_one();
}
