/******************************************************************************!
 * \file main.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include <jsonrpccpp/server/connectors/httpserver.h>
#include "build/abstractstubserver.h"

/******************************************************************************!
 * \class Server
 ******************************************************************************/
class Server : public AbstractStubServer
{
public:
    Server(jsonrpc::AbstractServerConnector& conn,
           jsonrpc::serverVersion_t type = jsonrpc::JSONRPC_SERVER_V2) :
        AbstractStubServer(conn, type) {}

    virtual std::string status() { return "ok"; }
    virtual void quit() { exit(0); }
};

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int, char**)
{
    jsonrpc::HttpServer httpserver(8383);
    Server s(httpserver, jsonrpc::JSONRPC_SERVER_V1V2);
    s.StartListening();

    for (;;) {
    }

    return 0;
}
