/******************************************************************************!
 * \file fft.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note http://www.fftw.org/benchfft/ffts.html
 ******************************************************************************/
#include <stdlib.h>
#include <stdint.h>
#include <signal.h>
#include <linux/tcp.h>
#include <complex.h>
#include <fftw3.h>
#include <math.h>
#include "debug.h"

void sockInit(int argc, char* argv[]);
ssize_t sockRead(unsigned char* buff, size_t count);
void sockQuit();

void plotInit(unsigned int samplesSize,
              const char* min,
              const char* max);
void plotShowSamples(fftw_complex* samples,
                     unsigned int min,
                     unsigned int max);
void plotShowFFT(fftw_complex* samples,
                 fftw_complex* output);
void plotQuit();

static fftw_complex* gSamples1 = NULL;
static fftw_complex* gSamples2 = NULL;
static fftw_complex* gSamples = NULL;
static fftw_complex* gOutput = NULL;
static fftw_plan gPlan1;
static fftw_plan gPlan2;

/******************************************************************************!
 * \fn controlC
 ******************************************************************************/
void
controlC(int sig)
{
    if (sig == SIGINT) {
        fftw_destroy_plan(gPlan1);
        fftw_destroy_plan(gPlan2);
        fftw_free(gOutput);
        fftw_free(gSamples1);
        fftw_free(gSamples2);
        sockQuit();
        plotQuit();
        exit(EXIT_SUCCESS);
    }
}

/******************************************************************************!
 * \fn initFFT
 ******************************************************************************/
static void
initFFT(unsigned int size)
{
    unsigned int i;

    gSamples1 = fftw_alloc_complex(size);
    if (! gSamples1) {
        ERROR("fftw_alloc_complex");
        exit(EXIT_FAILURE);
    }
    gSamples2 = fftw_alloc_complex(size);
    if (! gSamples2) {
        ERROR("fftw_alloc_complex");
        exit(EXIT_FAILURE);
    }
    gSamples = gSamples1;
    gOutput = fftw_alloc_complex(size);
    if (! gOutput) {
        ERROR("fftw_alloc_complex");
        exit(EXIT_FAILURE);
    }
    gPlan1 = fftw_plan_dft_1d(size,
                              gSamples1, gOutput, FFTW_FORWARD, FFTW_ESTIMATE);
    if (! gPlan1) {
        ERROR("fftw_plan_dft_1d");
        exit(EXIT_FAILURE);
    }
    gPlan2 = fftw_plan_dft_1d(size,
                              gSamples2, gOutput, FFTW_FORWARD, FFTW_ESTIMATE);
    if (! gPlan2) {
        ERROR("fftw_plan_dft_1d");
        exit(EXIT_FAILURE);
    }
    for (i = 0; i < size; ++i) {
        gSamples1[i] = 0;
        gSamples2[i] = 0;
        gOutput[i] = 0;
    }
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
    const unsigned int SAMPLES_SIZE = SAMPLE_SIZE;  // ariettaG25: build/adc 18
    //const unsigned int SAMPLES_SIZE = SAMPLE_SIZE << 3;  // G25: build/adc 13

    uint16_t buff[SAMPLES_SIZE >> 1];
    uint16_t uint2;
    double t;
    unsigned int samplesPos = 0;
    unsigned int savePos = 0;
    uint32_t count = 0;

    sockInit(argc, argv);

    DEBUG("TCP_MSS_DEFAULT = %d", TCP_MSS_DEFAULT);
    DEBUG("SAMPLE_SIZE = %u", SAMPLE_SIZE);
    DEBUG("PACKET_SIZE = %u", PACKET_SIZE);
    DEBUG("SAMPLES_SIZE = %u", SAMPLES_SIZE);

    plotInit(SAMPLES_SIZE, argv[1], argv[2]);
    initFFT(SAMPLES_SIZE);

    for (;;) {
        ssize_t len = sockRead((unsigned char*) buff, PACKET_SIZE) >> 1;
        uint32_t uint4 =
            (buff[0] << 16) +
            (buff[1]);
        int pos = 2;
        if (count != 0 && uint4 != count + 1) {
            ERROR("paquet voulu: %u, paquet recu:%u\n", count + 1, uint4);
        }
        count = uint4;
        uint4 =
            (buff[pos] << 16) +
            (buff[pos + 1]);
        pos += 2;
        if (uint4 != SAMPLE_SIZE) {
            ERROR("taille voulue: %u, taille recue:%u\n", SAMPLE_SIZE, uint4);
        }
        while (pos < len) {
            uint2 = buff[pos++];
            uint4 =
                (buff[pos] << 16) +
                (buff[pos + 1]);
            pos += 2;
            t = uint2 + (double) uint4 / 1000000;
            uint2 = buff[pos++];
            gSamples[samplesPos++] = t + I * uint2;
            if (pos >= len) {
                plotShowSamples(gSamples, savePos, samplesPos);
                savePos = samplesPos;
            }
            if (samplesPos == SAMPLES_SIZE) {
                if (gSamples == gSamples1) {
                    fftw_execute(gPlan1);
                } else {
                    fftw_execute(gPlan2);
                }
                plotShowFFT(gSamples, gOutput);
                if (gSamples != gSamples1) {
                    gSamples = gSamples1;
                } else {
                    gSamples = gSamples2;
                }
                samplesPos = 0;
                savePos = 0;
            }
        }
    }
}
