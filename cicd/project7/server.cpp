/******************************************************************************!
 * \file server.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <iostream>
#include <thread>
#include <string.h>

#include <nng/nng.h>
#include <nng/protocol/pair0/pair.h>

using namespace std::chrono_literals;

/******************************************************************************!
 * \fn reply
 ******************************************************************************/
bool
reply(nng_socket sock, const char* result)
{
    char* buf = NULL;
    size_t sz;
    int rv;

    rv = nng_recv(sock, &buf, &sz, NNG_FLAG_ALLOC);
    if (rv != 0) {
        std::cerr << "server: nng_recv "
                  << nng_strerror(rv) << std::endl;
        std::this_thread::sleep_for(100ms);
        return true;
    }
    std::cout << "server: recv "
              << buf << std::endl;
    if (strcmp(buf, "emit alert") == 0) {
        std::cout << "server: send alert"
                  << std::endl;
        rv = nng_send(sock, const_cast<char*>("alert"), strlen("alert") + 1, 0);
        if (rv != 0) {
            std::cerr << "server: nng_send "
                      << nng_strerror(rv) << std::endl;
        }
    }
    std::cout << "server: send "
              << result << std::endl;
    rv = nng_send(sock, const_cast<char*>(result), strlen(result) + 1, 0);
    if (rv != 0) {
        std::cerr << "server: nng_send "
                  << nng_strerror(rv) << std::endl;
    }

    if (strcmp(buf, "quit") == 0) {
        nng_free(buf, sz);
        return false;
    }
    nng_free(buf, sz);
    return true;
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
    int rv;

    if ((rv = nng_pair0_open(&sock)) != 0) {
        std::cerr << "server: nng_pair0_open "
                  << nng_strerror(rv) << std::endl;
    }
    if ((rv = nng_listen(sock, url, NULL, 0)) != 0) {
        std::cerr << "server: nng_listen "
                  << nng_strerror(rv) << std::endl;
    }
    if ((rv = nng_setopt_ms(sock, NNG_OPT_RECVTIMEO, 100)) != 0) {
        std::cerr << "server: nng_setopt_ms "
                  << nng_strerror(rv) << std::endl;
    }

    while (reply(sock, "ok")) {
        ;
    }

    return 0;
}
