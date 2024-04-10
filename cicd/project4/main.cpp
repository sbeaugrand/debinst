/******************************************************************************!
 * \file main.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include <jsonrpccpp/server/connectors/httpserver.h>
#include "build/abstractstubserver.h"
#include <thread>

/******************************************************************************!
 * \class Server
 ******************************************************************************/
class Server : public AbstractStubServer
{
public:
    explicit Server(jsonrpc::AbstractServerConnector& conn)
        : AbstractStubServer(conn, jsonrpc::JSONRPC_SERVER_V1V2) {
        this->StartListening();
    }
    virtual ~Server() {
        std::cout << "Server::dtor" << std::endl;
        this->StopListening();
    }
    virtual std::string status() override {
        return "ok";
    }
    virtual void quit() override {
        std::cout << "Server::quit" << std::endl;
        exit(0);
    }
};

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int, char**)
{
    jsonrpc::HttpServer httpserver(8383, "", "", 2);  // 2 threads
    Server server(httpserver);

    using namespace std::chrono_literals;
    for (;;) {
        std::this_thread::sleep_for(100ms);
    }

    return 0;
}
