/******************************************************************************!
 * \file client.cpp
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
 * \fn rpc
 ******************************************************************************/
void
rpc(nng_socket sock, const char* method)
{
    char* buf = NULL;
    size_t sz;
    int rv;

    std::cout << "client: send "
              << method << std::endl;
    if ((rv = nng_send(sock, const_cast<char*>(method),
                       strlen(method) + 1, 0)) != 0) {
        std::cerr << "client: nng_send "
                  << nng_strerror(rv) << std::endl;
    }
    std::cout << "client: recv ..."
              << std::endl;
    if ((rv = nng_recv(sock, &buf, &sz, NNG_FLAG_ALLOC)) != 0) {
        std::cerr << "client: nng_recv "
                  << nng_strerror(rv) << std::endl;
    }
    std::cout << "client: recv "
              << buf << std::endl;

    nng_free(buf, sz);
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
    nng_dialer dialer;
    int rv;

    if ((rv = nng_req0_open(&sock)) != 0) {
        std::cerr << "client: nng_socket "
                  << nng_strerror(rv) << std::endl;
    }
    if ((rv = nng_dialer_create(&dialer, sock, url)) != 0) {
        std::cerr << "client: nng_dialer_create "
                  << nng_strerror(rv) << std::endl;
    }
    nng_socket_set_ms(sock, NNG_OPT_REQ_RESENDTIME, 2000);
    nng_dialer_start(dialer, NNG_FLAG_NONBLOCK);

    rpc(sock, "status");
    rpc(sock, "quit");

    nng_close(sock);
    return 0;
}
