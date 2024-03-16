/******************************************************************************!
 * \file server.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <sockinet.h>

int
main()
{
    sockinetbuf s(sockbuf::sock_stream);
    s.bind(1234);
    s.listen();
    iosockinet sock = s.accept();

    char buff[512];
    while (sock >> buff) {
        std::cout << "server: recv " << buff << std::endl;
        if (std::string(buff) == "quit") {
            return 0;
        } else {
            sock << "ok\n" << std::flush;
        }
    }

    return 0;
}
