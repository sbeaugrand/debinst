/******************************************************************************!
 * \file Server.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "Server.h"

Server&
Server::instance()
{
    static Server inst = Server();
    return inst;
}

void
Server::open(int port)
{
    svr.Get("/", [](const httplib::Request& req,
                    httplib::Response& res) {
        if (req.get_param_value("f") == "html") {
            res.set_content(
                "<html>"
                "it works"
                "</html>\n",
                "text/html");
        } else {
            res.set_content(
                "it works\n",
                "text/plain");
        }
    });

    svr.Get("/kill", [](const httplib::Request& req,
                        httplib::Response& res) {
        if (req.get_param_value("f") == "html") {
            res.set_content(
                "<html>"
                "kill"
                "</html>\n",
                "text/html");
        } else {
            res.set_content(
                "kill\n",
                "text/plain");
        }
        Server::instance().close();
    });

    svr.listen("0.0.0.0", port);
}

void
Server::close()
{
    svr.stop();
}
