/******************************************************************************!
 * \file main.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <thread>
#include <variant>
#include <iostream>
#include <jsonrpccpp/server/connectors/httpserver.h>
#include "build/abstractstubserver.h"

/******************************************************************************!
 * \class Machine
 ******************************************************************************/
namespace state {
struct Ready {};
struct NotReady {};
struct Exit {};
}
using State = std::variant<state::Ready, state::NotReady, state::Exit>;

namespace event {
struct Init {};
struct Exit {};
}
using Event = std::variant<event::Init, event::Exit>;

State
onEvent(state::Ready state, const event::Init&) {
    return state;
}

State
onEvent(state::Ready  /*state*/, const event::Exit&) {
    return state::Exit{};
}

State
onEvent(state::NotReady  /*state*/, const event::Init&) {
    return state::Ready{};
}

State
onEvent(state::NotReady  /*state*/, const event::Exit&) {
    return state::Exit{};
}

State
onEvent(state::Exit state, const event::Init&) {
    return state;
}

State
onEvent(state::Exit state, const event::Exit&) {
    return state;
}

class Machine
{
public:
    ~Machine() {
        std::cout << "Machine::dtor" << std::endl;
    }
    void processEvent(const Event& event) {
        state = std::visit(
            [](const auto& st, const auto& ev) { return onEvent(st, ev); },
            state, event);
    }
    State state = state::NotReady{};
};

/******************************************************************************!
 * \class Server
 ******************************************************************************/
class Server : public AbstractStubServer
{
public:
    Server(jsonrpc::AbstractServerConnector& conn, Machine& m)
        : AbstractStubServer(conn, jsonrpc::JSONRPC_SERVER_V1V2)
        , machine(m) {
        this->StartListening();
    }
    virtual ~Server() {
        std::cout << "Server::dtor" << std::endl;
        this->StopListening();
    }
    virtual std::string status() override {
        return "ok";
    }
    virtual Json::Value object() override {
        Json::Value result;
        result["value"] = 0;
        if (std::holds_alternative<state::Ready>(machine.state)) {
            result["state"] = "ready";
        } else {
            result["state"] = "not ready";
        }
        return result;
    }
    virtual void quit() override {
        std::cout << "Server::quit" << std::endl;
        machine.processEvent(event::Exit{});
    }
private:
    Machine& machine;
};

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int, char**)
{
    Machine machine;
    jsonrpc::HttpServer httpserver(8383, "", "", 2);  // 2 threads
    Server server(httpserver, machine);

    using namespace std::chrono_literals;
    std::this_thread::sleep_for(2s);
    machine.processEvent(event::Init{});
    for (;;) {
        std::this_thread::sleep_for(100ms);
        if (std::holds_alternative<state::Exit>(machine.state)) {
            break;
        }
    }

    return 0;
}
