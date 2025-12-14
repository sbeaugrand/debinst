/******************************************************************************!
 * \file plot-gnuplot.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <complex.h>
#include <fftw3.h>
#include "debug.h"

static unsigned int gLoop = 1;

static fftw_complex* gPlotSamples = NULL;

static fftw_complex* gPlotSamplesFFT = NULL;
static fftw_complex* gPlotOutputFFT = NULL;

static pthread_t gThreadPlotFFT = 0;
static sem_t gSemFFT;
static FILE* gPlotFileFFT = NULL;

static pthread_t gThreadPlotSamples = 0;
static sem_t gSemSamples;
static FILE* gPlotFileSamples = NULL;
static unsigned int gPlotSamplesMin = 0;
static unsigned int gPlotSamplesMax = 0;

#ifdef PLOT_DEBUG
static FILE* gPlotDebug = NULL;
#endif

/******************************************************************************!
 * \fn threadPlotSamples
 ******************************************************************************/
static void*
threadPlotSamples(void* /*arg*/)
{
    static unsigned int last;
    unsigned int pos;

    for (;;) {
        sem_wait(&gSemSamples);
        if (! gLoop) {
            break;
        }
        if (gPlotSamplesMin == 0 ||
            gPlotSamplesMin < last) {
            fprintf(gPlotFileSamples, "unset multiplot\n");
            fprintf(gPlotFileSamples, "set multiplot\n");
        } else {
            --gPlotSamplesMin;
        }
        fprintf(gPlotFileSamples, "plot '-' w l\n");
        for (pos = gPlotSamplesMin;
             pos < gPlotSamplesMax; ++pos) {
            fprintf(gPlotFileSamples,
                    "%u %f\n", pos, cimag(gPlotSamples[pos]));
        }
        fprintf(gPlotFileSamples, "e\n");
        last = gPlotSamplesMax;
    }
    return NULL;
}

/******************************************************************************!
 * \fn threadPlotFFT
 ******************************************************************************/
static void*
threadPlotFFT(void* arg)
{
    const unsigned int SAMPLES_SIZE = *((unsigned int*) arg);
    unsigned int samplesPos;

    for (;;) {
        sem_wait(&gSemFFT);
        if (! gLoop) {
            break;
        }
        double duree = (creal(gPlotSamplesFFT[SAMPLES_SIZE - 1]) -
                        creal(gPlotSamplesFFT[0]));
        DEBUG("%d par seconde\n", (int) (SAMPLES_SIZE / duree));
        fprintf(gPlotFileFFT, "plot '-' w l\n");
#       ifdef PLOT_DEBUG
        fprintf(gPlotDebug, "plot '-' w l, (%f-%f)*x/%u+%f\n",
                creal(gPlotSamplesFFT[(SAMPLES_SIZE >> 1) - 1]),
                creal(gPlotSamplesFFT[0]),
                (SAMPLES_SIZE >> 1),
                creal(gPlotSamplesFFT[0]));
#       endif
        for (samplesPos = 1; samplesPos < (SAMPLES_SIZE >> 1); ++samplesPos) {
            fprintf(gPlotFileFFT, "%f %f\n",
                    samplesPos / duree,
                    cabs(gPlotOutputFFT[samplesPos]));
#           ifdef PLOT_DEBUG
            fprintf(gPlotDebug, "%f\n",
                    creal(gPlotSamplesFFT[samplesPos]));
#           endif
        }
        fprintf(gPlotFileFFT, "e\n");
#       ifdef PLOT_DEBUG
        fprintf(gPlotDebug, "e\n");
#       endif
    }
    return NULL;
}

/******************************************************************************!
 * \fn plotInit
 ******************************************************************************/
void
plotInit(unsigned int samplesSize,
         const char* min,
         const char* max)
{
    static unsigned int SAMPLES_SIZE = 0;

    gPlotFileFFT = popen("gnuplot", "w");
    setlinebuf(gPlotFileFFT);
    fprintf(gPlotFileFFT, "set mxtics\n");
    fprintf(gPlotFileFFT, "set xtics out 10\n");
    fprintf(gPlotFileFFT, "set xrange[%s:%s]\n", min, max);
    gPlotFileSamples = popen("gnuplot", "w");
    setlinebuf(gPlotFileSamples);
    fprintf(gPlotFileSamples, "set xrange[0:%u]\n", samplesSize);
    fprintf(gPlotFileSamples, "set yrange[-10:2500]\n");
    fprintf(gPlotFileSamples, "set multiplot\n");
#   ifdef PLOT_DEBUG
    gPlotDebug = popen("gnuplot", "w");
    setlinebuf(gPlotDebug);
#   endif

    if (SAMPLES_SIZE == 0) {
        SAMPLES_SIZE = samplesSize;
    }

    if (pthread_create(&gThreadPlotSamples, NULL,
                       &threadPlotSamples, (void*) &SAMPLES_SIZE) != 0) {
        ERROR("pthread_create");
        exit(EXIT_FAILURE);
    }
    sem_init(&gSemSamples, 0, 0);

    if (pthread_create(&gThreadPlotFFT, NULL,
                       &threadPlotFFT, (void*) &SAMPLES_SIZE) != 0) {
        ERROR("pthread_create");
        exit(EXIT_FAILURE);
    }
    sem_init(&gSemFFT, 0, 0);
}

/******************************************************************************!
 * \fn plotShowSamples
 ******************************************************************************/
void
plotShowSamples(fftw_complex* samples,
                unsigned int min,
                unsigned int max)
{
    int semValue;

    sem_getvalue(&gSemSamples, &semValue);
    if (semValue <= 0) {
        gPlotSamples = samples;
        gPlotSamplesMin = min;
        gPlotSamplesMax = max;
        sem_post(&gSemSamples);
    }
}

/******************************************************************************!
 * \fn plotShowFFT
 ******************************************************************************/
void
plotShowFFT(fftw_complex* samples,
            fftw_complex* output)
{
    int semValue;

    sem_getvalue(&gSemFFT, &semValue);
    if (semValue <= 0) {
        gPlotSamplesFFT = samples;
        gPlotOutputFFT = output;
        sem_post(&gSemFFT);
    }
}

/******************************************************************************!
 * \fn plotQuit
 ******************************************************************************/
void
plotQuit()
{
    void* res;

    if (gPlotFileFFT != 0) {
        fclose(gPlotFileFFT);
    }
    if (gPlotFileSamples != 0) {
        fclose(gPlotFileSamples);
    }
#   ifdef PLOT_DEBUG
    if (gPlotDebug != 0) {
        fclose(gPlotDebug);
    }
#   endif
    gLoop = 0;
    sem_post(&gSemSamples);
    pthread_join(gThreadPlotSamples, &res);
    sem_post(&gSemFFT);
    pthread_join(gThreadPlotFFT, &res);
}
