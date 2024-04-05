/******************************************************************************!
 * \file adc.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <sys/time.h>
#include <math.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <linux/tcp.h>
#include <time.h>
#include "wiring.h"
#include "debug.h"

#define CLOCK CLOCK_REALTIME

#ifdef SINUS
void analogSetFrequencies(int argc, char* argv[]);
#endif

const char* PORT = "4040";
int gSock = 0;
struct timespec gTimeval;
time_t gOffset;

/******************************************************************************!
 * \fn controlC
 ******************************************************************************/
void
controlC(int sig)
{
    if (sig == SIGINT) {
        analogQuit();
        if (gSock != 0) {
            close(gSock);
        }
        exit(EXIT_SUCCESS);
    }
}

/******************************************************************************!
 * \fn sockInit
 ******************************************************************************/
void
sockInit(const char* port)
{
    struct addrinfo ahints;
    struct addrinfo* ares;
    struct addrinfo* aiter;

    memset(&ahints, 0, sizeof(struct addrinfo));
    ahints.ai_family = AF_INET;
    ahints.ai_socktype = SOCK_DGRAM;
    ahints.ai_flags = AI_PASSIVE;
    ahints.ai_protocol = IPPROTO_UDP;
    ahints.ai_canonname = NULL;
    ahints.ai_addr = NULL;
    ahints.ai_next = NULL;
    if (getaddrinfo(NULL, port, &ahints, &ares) != 0) {
        ERRNO("getaddrinfo");
        exit(EXIT_FAILURE);
    }
    for (aiter = ares; aiter != NULL; aiter = aiter->ai_next) {
        if ((gSock = socket(aiter->ai_family,
                            aiter->ai_socktype,
                            aiter->ai_protocol)) == -1) {
            continue;
        }
        if (bind(gSock, aiter->ai_addr, aiter->ai_addrlen) == 0) {
            break;
        }
        close(gSock);
        gSock = 0;
    }
    if (aiter == NULL) {
        ERROR("bind");
        exit(EXIT_FAILURE);
    }
    freeaddrinfo(ares);
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char* argv[])
{
    const unsigned int HEADER_SIZE = sizeof(uint32_t) << 1;
    const unsigned int SAMPLE_SIZE = 1 << (int) log2(TCP_MSS_DEFAULT -
                                                     HEADER_SIZE);
    const unsigned int PACKET_SIZE = HEADER_SIZE + SAMPLE_SIZE;

    struct sockaddr_in addr;
    uint16_t buff[PACKET_SIZE >> 1];
    unsigned int pos;
    uint16_t uint2;
    uint32_t uint4;
    socklen_t slen = sizeof(addr);
    uint32_t count;

#   ifdef ARIETTA
    uint32_t sleep;
    if (argc > 1) {
        sleep = 1 << atoi(argv[1]);
    } else {
        sleep = 1 << 18;
    }
#   else
    struct timespec ts;
    DEBUG("TCP_MSS_DEFAULT = %d", TCP_MSS_DEFAULT);
    DEBUG("SAMPLE_SIZE = %u", SAMPLE_SIZE);
    DEBUG("PACKET_SIZE = %u", PACKET_SIZE);
    clock_getres(CLOCK_REALTIME, &ts);
    DEBUG("%lu.%09lu CLOCK_REALTIME", ts.tv_sec, ts.tv_nsec);
    clock_getres(CLOCK_MONOTONIC, &ts);
    DEBUG("%lu.%09lu CLOCK_MONOTONIC", ts.tv_sec, ts.tv_nsec);
    clock_getres(CLOCK_MONOTONIC_RAW, &ts);
    DEBUG("%lu.%09lu CLOCK_MONOTONIC_RAW", ts.tv_sec, ts.tv_nsec);
    clock_getres(CLOCK_PROCESS_CPUTIME_ID, &ts);
    DEBUG("%lu.%09lu CLOCK_PROCESS_CPUTIME_ID", ts.tv_sec, ts.tv_nsec);
    clock_getres(CLOCK_THREAD_CPUTIME_ID, &ts);
    DEBUG("%lu.%09lu CLOCK_THREAD_CPUTIME_ID", ts.tv_sec, ts.tv_nsec);
    if (argc > 1) {
        ts.tv_sec = 0;
        ts.tv_nsec = 1000000000 / atoi(argv[1]);
    } else {
        ts.tv_sec = 0;
        ts.tv_nsec = 1;
    }
#   endif

#   ifdef SINUS
    analogSetFrequencies(argc, argv);
#   endif
    if (! analogInit()) {
        ERROR("analogInit");
        exit(EXIT_FAILURE);
    }

    if (clock_gettime(CLOCK, &gTimeval) < 0) {
        ERRNO("clock_gettime");
        exit(EXIT_FAILURE);
    }
    gOffset = gTimeval.tv_sec;

    count = 0;
    pos = 0;
    buff[pos++] = 0;
    buff[pos++] = 0;
    buff[pos++] = SAMPLE_SIZE >> 16;
    buff[pos++] = SAMPLE_SIZE & 0xFFFFu;

    if (signal(SIGINT, controlC) == SIG_ERR) {
        ERRNO("signal");
        exit(EXIT_FAILURE);
    }

    sockInit(PORT);
    if (recvfrom(gSock, buff, PACKET_SIZE, 0,
                 (struct sockaddr*) &addr, &slen) < 0) {
        ERRNO("recvfrom");
        exit(EXIT_FAILURE);
    }

    for (;;) {
        if (clock_gettime(CLOCK, &gTimeval) < 0) {
            ERRNO("clock_gettime");
            exit(EXIT_FAILURE);
        }
        uint2 = (uint16_t) (gTimeval.tv_sec - gOffset);
        buff[pos++] = uint2;
        uint4 = (uint32_t) (gTimeval.tv_nsec / 1000);
        buff[pos++] = uint4 >> 16;
        buff[pos++] = uint4 & 0xFFFFu;
        buff[pos++] = analogRead(0);
        if (pos == (PACKET_SIZE >> 1)) {
            if (sendto(gSock, buff, pos << 1, 0,
                       (struct sockaddr*) &addr, slen) < 0) {
                ERRNO("send");
                exit(EXIT_FAILURE);
            }
            ++count;
            pos = 0;
            buff[pos++] = count >> 16;
            buff[pos++] = count & 0xFFFFu;
            buff[pos++] = SAMPLE_SIZE >> 16;
            buff[pos++] = SAMPLE_SIZE & 0xFFFFu;
        }
#       ifdef ARIETTA
        for (uint4 = 0; uint4 < sleep; ++uint4) {
            ;
        }
#       else
        clock_nanosleep(CLOCK, 0, &ts, NULL);
#       endif
    }
}
