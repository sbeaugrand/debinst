/******************************************************************************!
 * \file client.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <sockinet.h>

int
main()
{
    iosockinet sock(sockbuf::sock_stream);
    sock->connect("localhost", 1234);

    std::cout << "client: send status" << std::endl;
    sock << "status\n" << std::flush;

    char buff[512];
    sock >> buff;
    std::cout << "client: recv " << buff << std::endl;

    std::cout << "client: send quit" << std::endl;
    sock << "quit\n" << std::flush;

    return 0;
}
