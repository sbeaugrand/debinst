/******************************************************************************!
 * \file fft-tcp.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <linux/tcp.h>
#include "debug.h"

const char* PORT = "4040";
int gSock = 0;

/******************************************************************************!
 * \fn sockInit
 ******************************************************************************/
void sockInit(int argc, char* argv[])
{
    struct addrinfo ahints;
    struct addrinfo* ares;
    struct addrinfo* aiter;
    unsigned char buff[5];
    ssize_t len;

    if (argc != 4) {
        ERROR("Usage: %s <frequence-min> <frequence-max> <adresse>", argv[0]);
        exit(EXIT_FAILURE);
    }

    memset(&ahints, 0, sizeof(struct addrinfo));
    ahints.ai_family = AF_INET;
    ahints.ai_socktype = SOCK_DGRAM;
    ahints.ai_flags = AI_PASSIVE;
    ahints.ai_protocol = IPPROTO_UDP;
    ahints.ai_canonname = NULL;
    ahints.ai_addr = NULL;
    ahints.ai_next = NULL;
    if (getaddrinfo(argv[3], PORT, &ahints, &ares) != 0) {
        ERRNO("getaddrinfo");
        exit(EXIT_FAILURE);
    }
    for (aiter = ares; aiter != NULL; aiter = aiter->ai_next) {
        if ((gSock = socket(aiter->ai_family,
                            aiter->ai_socktype,
                            aiter->ai_protocol)) == -1) {
            continue;
        }
        if (connect(gSock, aiter->ai_addr, aiter->ai_addrlen) == 0) {
            break;
        }
        close(gSock);
        gSock = 0;
    }
    if (aiter == NULL) {
        ERROR("connect");
        exit(EXIT_FAILURE);
    }
    freeaddrinfo(ares);

    if (write(gSock, "helo", 5) != 5) {
        ERRNO("write");
        exit(EXIT_FAILURE);
    }
    if ((len = read(gSock, buff, 5)) != 5) {
        ERRNO("read");
        exit(EXIT_FAILURE);
    }
    DEBUG("%s", buff);
}

/******************************************************************************!
 * \fn sockRead
 ******************************************************************************/
ssize_t sockRead(unsigned char* buff, size_t count)
{
    ssize_t len;

    if ((len = read(gSock, buff, count)) < 0) {
        DEBUG("read");
        exit(EXIT_FAILURE);
    }

    return len;
}

/******************************************************************************!
 * \fn sockQuit
 ******************************************************************************/
void sockQuit()
{
    if (gSock != 0) {
        close(gSock);
    }
}
