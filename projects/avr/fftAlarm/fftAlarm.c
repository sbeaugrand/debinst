/******************************************************************************!
 * \file fftAlarm.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note echo | awk '{ print 8000000 / 64 }'  # 125000 < 200 kHz
 *       echo | awk '{ print 8000000 / 64 / 13 }'  # 9615.38 = Sample rate
 ******************************************************************************/
#include <math.h>
#include "common.h"
#define FPS_O 4
#define FPS 16  // 2 ^ FPS_O

#ifdef tinyX5
# include <avr/io.h>
# include "wiring.h"
#else
# include <stdio.h>
# include <stdint.h>
# include <unistd.h>
# include <stdlib.h>
# include <string.h>
const ssize_t BUFF_MEMSIZE = N * sizeof(int16_t);
const ssize_t OUT_MEMSIZE = N >> 1;
#endif

int16_t fix_fft(int8_t fr[], int8_t fi[], int16_t m, int16_t inverse);

int16_t buff[N];
int8_t data[N];
int8_t im[N];
int gSkipCount;
int gAlarmPulse;
int gAlarmSpace;
int gAlarm;
int gAlarmCount;

/******************************************************************************!
 * \fn setup
 ******************************************************************************/
void
setup()
{
#   ifdef tinyX5
    analogInit();
    digitalInit(PINB4, OUTPUT);
    digitalInit(PINB2, OUTPUT);
    digitalInit(PINB1, OUTPUT);
    digitalInit(PINB0, OUTPUT);
    digitalWrite(PINB4, 0);
    digitalWrite(PINB2, ADCSRA & 1);
    digitalWrite(PINB1, ADCSRA & 2);
    digitalWrite(PINB0, ADCSRA & 4);
#   endif
    gSkipCount = 0;
    gAlarmPulse = 0;
    gAlarmSpace = 0;
    gAlarm = 0;
    gAlarmCount = 0;
}

/******************************************************************************!
 * \fn loop
 ******************************************************************************/
void
loop()
{
    int i;
    int j;
    int k;
    int32_t adc;
    int min;

#   ifdef tinyX5
    while ((adc = analogRead(PINB3)) < 0) {
        ;
    }
    buff[0] = adc;
    min = adc;
    for (i = 1; i < N; ++i) {
        while ((adc = analogRead(PINB3)) < 0) {
            ;
        }
        buff[i] = adc;
        if (min > adc) {
            min = adc;
        }
    }
#   else
    ssize_t t = 0;
    ssize_t s;
    do {
        s = read(STDIN_FILENO, buff + t, BUFF_MEMSIZE - t);
        if (s <= 0) {
            fprintf(stderr, "fftAlarm: EOF\n");
            exit(EXIT_SUCCESS);
        }
        t += s;
    } while (t < BUFF_MEMSIZE);
    min = buff[0];
    for (i = 1; i < N; ++i) {
        if (min > buff[i]) {
            min = buff[i];
        }
    }
#   endif

    if (++gSkipCount < (RATE >> (M + FPS_O))) {
        return;
    }
    gSkipCount = 0;
#   ifndef tinyX5
    fprintf(stderr, ".");
#   endif

    k = 15;
    for (i = 0; i < N; ++i) {
        buff[i] -= min;
        adc = buff[i];
        for (j = k; (adc << j) > 32767 && j > 0; --j) {
            ;
        }
        if (k > j) {
            k = j;
        }
    }

    int32_t sum = 0;
    for (i = 0; i < N; ++i) {
        if (k & 8) {  // k >= 8
            data[i] = buff[i];
        } else {
            data[i] = buff[i] >> (8 - k);
        }
        sum += data[i];
    }
    int avg = sum / N;
    for (i = 0; i < N; i++) {
        data[i] -= avg;
        im[i] = 0;
    }

    fix_fft(data, im, M, 0);

    int32_t max = 0;
    j = -1;
    for (i = 0; i < (N >> 1); ++i) {
        sum = (data[i] < 0) ? -data[i] : data[i];
        sum += (im[i] < 0) ? -im[i] : im[i];
        if (max < sum) {
            max = sum;
            j = i;
        }
#       ifndef tinyX5
        data[i] = sqrt(data[i] * data[i] + im[i] * im[i]);
#       endif
    }

#  ifndef tinyX5
#   ifndef NDEBUG
    if (j >= 0) {
        fprintf(stderr, "j=%d, freq=%d-%d, level=%d\n",
                j, (j * RATE) >> M, ((j + 1) * RATE) >> M, avg);
    }
#   endif
#  endif
    if (j >= 0) {
        j *= RATE >> M;
    }

#   ifdef tinyX5
    if (gAlarmCount) {
    } else if (j < 0) {
        digitalWrite(PINB2, 0);
        digitalWrite(PINB1, 0);
        digitalWrite(PINB0, 0);
    } else {
        if (j <= 1000) {
            digitalWrite(PINB2, 1);
            digitalWrite(PINB1, 0);
            digitalWrite(PINB0, 0);
        } else if (j <= 2000) {
            digitalWrite(PINB2, 0);
            digitalWrite(PINB1, 1);
            digitalWrite(PINB0, 0);
        } else if (j <= 3000) {
            digitalWrite(PINB2, 1);
            digitalWrite(PINB1, 1);
            digitalWrite(PINB0, 0);
        } else if (j <= 4000) {
            digitalWrite(PINB2, 0);
            digitalWrite(PINB1, 0);
            digitalWrite(PINB0, 1);
        } else if (j <= 5000) {
            digitalWrite(PINB2, 1);
            digitalWrite(PINB1, 0);
            digitalWrite(PINB0, 1);
        } else if (j <= 6000) {
            digitalWrite(PINB2, 0);
            digitalWrite(PINB1, 1);
            digitalWrite(PINB0, 1);
        } else {
            digitalWrite(PINB2, 1);
            digitalWrite(PINB1, 1);
            digitalWrite(PINB0, 1);
        }
    }
#   endif

    if (j > 3000 && j <= 4000) {
        if (gAlarm == 0 && ++gAlarmPulse >= FPS) {
            // [3000Hz, 4000Hz[ pendant au moins 1 seconde
            // avec espaces ne depassant pas 1.5 seconde
            // __________------______------______------__________
            //            0.5s  0.5s  0.5s  0.5s  0.5s
            ++gAlarmCount;
#           ifdef tinyX5
            if (gAlarmCount == 1 || gAlarmCount == 24) {  // 24 * 2.5s = 60s
                digitalWrite(PINB4, 1);
            }
            digitalWrite(PINB2, gAlarmCount & 1);
            digitalWrite(PINB1, gAlarmCount & 2);
            digitalWrite(PINB0, gAlarmCount & 4);
#           else
            fprintf(stderr, "Alarme = %d\n", 1);
#           endif
            gAlarm = FPS >> 2;
            gAlarmPulse = 0;
            gAlarmSpace = 0;
        }
    } else if (gAlarmPulse > 0) {
        if (gAlarm == 0 && ++gAlarmSpace >= FPS + (FPS >> 1)) {
#           ifndef tinyX5
            fprintf(stderr, "Pulse = %d\n", gAlarmPulse);
#           endif
            gAlarmPulse = 0;
            gAlarmSpace = 0;
        }
    }

#   ifndef tinyX5
    if (write(STDOUT_FILENO, data, OUT_MEMSIZE) < OUT_MEMSIZE) {
        fprintf(stderr, "error: write\n");
        exit(EXIT_FAILURE);
    }
#   endif

    if (gAlarm == 1) {
#       ifdef tinyX5
        digitalWrite(PINB4, 0);
#       else
        fprintf(stderr, "Alarme = %d\n", 0);
#       endif
        gAlarm = 0;
    } else if (gAlarm > 1) {
        --gAlarm;
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main()
{
    setup();
    for (;;) {
        loop();
    }
}
