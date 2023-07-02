/******************************************************************************!
 * \file server.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include <string.h>

#include <nng/nng.h>
#include <nng/protocol/reqrep0/rep.h>
#include <nng/protocol/reqrep0/req.h>

/******************************************************************************!
 * \fn reply
 ******************************************************************************/
void
reply(nng_socket sock, const char* result)
{
    int rv;

    std::cout << "server: send "
              << result << std::endl;
    rv = nng_send(sock, const_cast<char*>(result), strlen(result) + 1, 0);
    if (rv != 0) {
        std::cerr << "server: nng_send "
                  << nng_strerror(rv) << std::endl;
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    if (argc != 2) {
        return 1;
    }
    const char* url = argv[1];
    nng_socket sock;
    nng_listener listener;
    int rv;

    if ((rv = nng_rep0_open(&sock)) != 0) {
        std::cerr << "server: nng_rep0_open "
                  << nng_strerror(rv) << std::endl;
    }
    if ((rv = nng_listener_create(&listener, sock, url)) != 0) {
        std::cerr << "server: nng_listener_create "
                  << nng_strerror(rv) << std::endl;
    }
    nng_socket_set_ms(sock, NNG_OPT_REQ_RESENDTIME, 2000);
    nng_listener_start(listener, 0);

    bool loop = true;
    while (loop) {
        char* buf = NULL;
        size_t sz;
        std::cout << "server: recv ..."
                  << std::endl;
        if ((rv = nng_recv(sock, &buf, &sz, NNG_FLAG_ALLOC)) != 0) {
            std::cerr << "server: nng_recv "
                      << nng_strerror(rv) << std::endl;
        }
        std::cout << "server: recv "
                  << buf << std::endl;
        if (strcmp(buf, "status") == 0) {
            reply(sock, "ok");
        } else if (strcmp(buf, "quit") == 0) {
            reply(sock, "ok");
            loop = false;
        } else {
            std::cout << "server: unkown method"
                      << std::endl;
        }
        nng_free(buf, sz);
    }

    return 0;
}
