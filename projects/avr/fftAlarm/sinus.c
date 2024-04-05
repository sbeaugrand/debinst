/******************************************************************************!
 * \file sinus.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
#include <signal.h>
#include <sys/time.h>
#include <errno.h>
#include "wiring.h"
#include "common.h"
void analogSetFrequencies(int argc, char* argv[]);

extern char** gArgv;
extern double gVPeak;

struct timespec gTimeval;
struct timespec gOffset;
int gCount;

int16_t buff[N];

void
sigalarm_handler(int s) {
    s = s;
}

/******************************************************************************!
 * \fn sampleRate
 ******************************************************************************/
int
sampleRate()
{
    double t = gTimeval.tv_sec - gOffset.tv_sec +
        (gTimeval.tv_nsec - gOffset.tv_nsec) / 1000000000L;
    return (gCount << M) / t;
}

/******************************************************************************!
 * \fn quit
 ******************************************************************************/
void
quit(int status)
{
    if (status == EXIT_SUCCESS) {
        fprintf(stderr, "Sample rate = %d Hz\n", sampleRate());
    }
    exit(status);
}

/******************************************************************************!
 * \fn sigpipe
 ******************************************************************************/
void
sigpipe(int sig)
{
    if (sig == SIGPIPE) {
        quit(EXIT_SUCCESS);
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char* argv[])
{
    char freqStr[16];
    int freq = atoi(argv[2]);

    analogSetFrequencies(argc, argv);
    analogInit();
    gVPeak = 51.0;

    if (signal(SIGPIPE, sigpipe) == SIG_ERR) {
        perror("signal");
        exit(EXIT_FAILURE);
    }

    struct sigaction sa;
    sa.sa_handler = sigalarm_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(SIGALRM, &sa, NULL) != 0) {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }

    struct itimerval it = { { 0, 1000000 / RATE }, { 0, 1000000 / RATE } };
    if (setitimer(ITIMER_REAL, &it, 0) != 0) {
        perror("setitimer");
        exit(EXIT_FAILURE);
    }

    if (clock_gettime(CLOCK_REALTIME, &gTimeval) < 0) {
        perror("clock_gettime");
        exit(EXIT_FAILURE);
    }
    gOffset.tv_sec = gTimeval.tv_sec;
    gOffset.tv_nsec = gTimeval.tv_nsec;

    for (gCount = 0; gCount < 5000; ++gCount) {
        for (int i = 0; i < N; ++i) {
            if (clock_gettime(CLOCK_REALTIME, &gTimeval) < 0) {
                perror("clock_gettime");
                quit(EXIT_FAILURE);
            }
            buff[i] = analogRead(0);
            if (select(0, 0, 0, 0, 0) >= 0 || errno != EINTR) {
                perror("select");
                quit(EXIT_FAILURE);
            }
        }
        if (write(STDOUT_FILENO, buff, N << 1) < 0) {
            perror("write");
            quit(EXIT_FAILURE);
        }
        if (gCount < 599) {
            switch (gCount) {
            case 75:
                gArgv[1] = "3500";
                break;
            case 150:  // 150 = 9615 / 64 = RATE / N
                gArgv[1] = "200";
                break;
            case 225:
                gArgv[1] = "3500";
                break;
            case 300:
                gArgv[1] = "200";
                break;
            case 375:
                gArgv[1] = "3500";
                break;
            case 450:
                gArgv[1] = "200";
                break;
            case 525:
                freq = 2000;
                sprintf(freqStr, "%d", freq);
                gArgv[1] = freqStr;
                break;
            }
        } else if (gCount % 100 == 99) {
            freq += 100;
            sprintf(freqStr, "%d", freq);
            gArgv[1] = freqStr;
        }
    }
    quit(EXIT_SUCCESS);
}
