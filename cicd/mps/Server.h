/******************************************************************************!
 * \file Server.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#pragma once
#include <atomic>
#include <jsonrpccpp/server/connectors/httpserver.h>
#include "abstractstubserver.h"

class List;
class Player;

/******************************************************************************!
 * \class Server
 ******************************************************************************/
class Server : public AbstractStubServer
{
public:
    Server(jsonrpc::AbstractServerConnector& conn,
           List& list,
           Player& player);
    virtual ~Server();
    virtual Json::Value list() override;
    virtual Json::Value info() override;
    virtual Json::Value rand() override;
    virtual Json::Value ok() override;
    virtual Json::Value play() override;
    virtual Json::Value pause() override;
    virtual Json::Value stop() override;
    virtual Json::Value prev() override;
    virtual Json::Value next() override;
    virtual Json::Value artist() override;
    virtual Json::Value album(const std::string& artist, int pos) override;
    virtual Json::Value pos(int pos) override;
    virtual Json::Value dir(const std::string& path) override;
    virtual std::string musicDirectory() override;
    virtual void quit() override;

    std::atomic_bool loop = true;
    List& mList;
    Player& mPlayer;
    std::string mSelect;
    std::chrono::time_point<std::chrono::steady_clock> mSelectTime;
};
