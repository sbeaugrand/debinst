/******************************************************************************!
 * \file Server.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <httplib.h>

class Server
{
public:
    static Server& instance();
    void open(int port);
    void close();
private:
    Server() {};

    httplib::Server svr;
};
