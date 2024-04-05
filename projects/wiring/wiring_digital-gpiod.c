/******************************************************************************!
 * \file wiring_digital-gpiod.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <gpiod.h>
#include "wiring.h"
#include "debug.h"

#define GPIOD_MAX_PIN_COUNT 24
struct gpiod_chip* chips[GPIOD_MAX_PIN_COUNT] = { NULL };
struct gpiod_line* lines[GPIOD_MAX_PIN_COUNT] = { NULL };

#ifndef NDEBUG
/******************************************************************************!
 * \fn debugValues
 ******************************************************************************/
void
debugValues()
{
    int n;
    int i;

    n = 0;
    for (i = 0; i < GPIOD_MAX_PIN_COUNT; ++i) {
        if (lines[i] != NULL) {
            fprintf(stderr, "%d ", gpiod_line_get_value(lines[i]));
            ++n;
        }
    }
    if (n > 0) {
        fprintf(stderr, "\n");
    }
}
#endif

/******************************************************************************!
 * \fn digitalInit
 ******************************************************************************/
int
digitalInit(uint8_t pin, uint8_t mode)
{
    struct gpiod_chip* chip;
    struct gpiod_line* line;
    char buf[6];

    line = lines[pin - 1];
    if (line == NULL) {
        if (snprintf(buf, 6, "pin%u", pin) >= 6) {
            ERROR("snprintf");
            return 1;
        }
        line = gpiod_line_find(buf);
        if (line == NULL) {
            ERROR("gpiod_line_find");
            return 2;
        }
        lines[pin - 1] = line;
        chip = gpiod_line_get_chip(line);
        chips[pin - 1] = chip;
    }

    if (gpiod_line_is_requested(line)) {
        gpiod_line_release(line);
    }
    if (mode == INPUT) {
        if (gpiod_line_request_input(line, "wiring") < 0) {
            ERRNO("gpiod_line_request_input");
            return 3;
        }
    } else {
        if (gpiod_line_request_output(line, "wiring", 0) < 0) {
            ERRNO("gpiod_line_request_output");
            return 3;
        }
    }

    return 0;
}

/******************************************************************************!
 * \fn digitalRead
 ******************************************************************************/
int
digitalRead(uint8_t pin)
{
    struct gpiod_line* line;
    int val;

#   ifndef NDEBUG
    debugValues();
#   endif
    line = lines[pin - 1];
    if (line == NULL) {
        ERROR("line == NULL");
        return -1;
    }

    val = gpiod_line_get_value(line);
    if (val < 0) {
        ERROR("gpiod_line_get_value");
        return GPIO_ERROR_READ;
    }
    return val;
}

/******************************************************************************!
 * \fn digitalWrite
 ******************************************************************************/
void
digitalWrite(uint8_t pin, uint8_t val)
{
    struct gpiod_line* line;

#   ifndef NDEBUG
    debugValues();
#   endif
    line = lines[pin - 1];
    if (line == NULL) {
        ERROR("line == NULL");
        return;
    }

    gpiod_line_set_value(line, val);
}

/******************************************************************************!
 * \fn digitalQuit
 ******************************************************************************/
int
digitalQuit(uint8_t pin)
{
    struct gpiod_chip* chip;
    struct gpiod_line* line;
    int i;

#   ifndef NDEBUG
    debugValues();
#   endif
    line = lines[pin - 1];
    if (line == NULL) {
        ERROR("line == NULL");
        return 1;
    }
    gpiod_line_release(line);
    lines[pin - 1] = NULL;

    chip = chips[pin - 1];
    if (chip == NULL) {
        ERROR("chip == NULL");
        return 2;
    }
    chips[pin - 1] = NULL;
    for (i = 0; i < GPIOD_MAX_PIN_COUNT; ++i) {
        if (chips[i] == chip) {
            return 0;
        }
    }
    gpiod_chip_close(chip);

    return 0;
}
