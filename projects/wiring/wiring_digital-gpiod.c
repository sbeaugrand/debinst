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
struct gpiod_chip*         chips[GPIOD_MAX_PIN_COUNT] = { NULL };
struct gpiod_line_request* lines[GPIOD_MAX_PIN_COUNT] = { NULL };
int                        offss[GPIOD_MAX_PIN_COUNT] = { 0 };

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
        if (lines[i]) {
            fprintf(stderr, "%d ", gpiod_line_get_value(lines[i], offss[i]));
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
    struct gpiod_line_request* line;
    char buf[6];
    int offset;

    chip = chips[pin - 1];
    line = lines[pin - 1];
    offset = offss[pin - 1];
    if (! line) {
        if (snprintf(buf, 6, "pin%u", pin) >= 6) {
            ERROR("snprintf");
            return 1;
        }
        chip = gpiod_chip_open("/dev/gpiochip0");
        if (! chip) {
            ERROR("gpiod_chip_open");
            return 2;
        }
        offset = gpiod_chip_get_line_offset_from_name(chip, buf);
        if (offset < 0) {
            ERRNO("gpiod_chip_get_line_offset_from_name");
            return 2;
        }
        chips[pin - 1] = chip;
    }

    //line_info = gpiod_chip_get_line_info(chip, offset);
    //if (! line_info) {
    //    ERROR("gpiod_chip_get_line_info");
    //    return 2;
    //}
    //if (gpiod_line_info_is_used(line_info)) {
    //    gpiod_line_request_release(line);
    //}
    struct gpiod_line_settings* settings = gpiod_line_settings_new();
    if (! settings) {
        ERRNO("gpiod_line_settings_new");
        return 3;
    }
    if (mode == INPUT) {
        if (gpiod_line_settings_set_direction(settings, GPIOD_LINE_DIRECTION_INPUT) < 0) {
            ERRNO("gpiod_line_settings_set_direction");
            return 3;
        }
    } else {
        if (gpiod_line_settings_set_direction(settings, GPIOD_LINE_DIRECTION_OUTPUT) < 0) {
            ERRNO("gpiod_line_settings_set_direction");
            return 3;
        }
    }
    struct gpiod_line_config* cfg = gpiod_line_config_new();
    if (! cfg) {
        ERRNO("gpiod_line_config_new");
        return 3;
    }
    unsigned int offsets = offset;
    if (gpiod_line_config_add_line_settings(cfg, &offsets, 1, settings) < 0)
    {
        ERRNO("gpiod_line_config_add_line_settings");
        return 3;
    }

    if (! line) {
        line = gpiod_chip_request_lines(chip, NULL, cfg);
        if (! line) {
            ERRNO("gpiod_chip_request_lines");
            return 3;
        }
        lines[pin - 1] = line;
        offss[pin - 1] = offset;
    }
    gpiod_line_settings_free(settings);
    gpiod_line_config_free(cfg);

    return 0;
}

/******************************************************************************!
 * \fn digitalRead
 ******************************************************************************/
int
digitalRead(uint8_t pin)
{
    struct gpiod_line_request* line;
    int val;

#   ifndef NDEBUG
    debugValues();
#   endif
    line = lines[pin - 1];
    if (! line) {
        ERROR("line == NULL");
        return -1;
    }

    val = gpiod_line_request_get_value(line, offss[pin - 1]);
    if (val < 0) {
        ERROR("gpiod_line_request_get_value");
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
    struct gpiod_line_request* line;

#   ifndef NDEBUG
    debugValues();
#   endif
    line = lines[pin - 1];
    if (! line) {
        ERROR("line == NULL");
        return;
    }

    gpiod_line_request_set_value(line, offss[pin - 1], val);
}

/******************************************************************************!
 * \fn digitalQuit
 ******************************************************************************/
int
digitalQuit(uint8_t pin)
{
    struct gpiod_chip* chip;
    struct gpiod_line_request* line;
    int i;

#   ifndef NDEBUG
    debugValues();
#   endif
    line = lines[pin - 1];
    if (! line) {
        ERROR("line == NULL");
        return 1;
    }
    gpiod_line_request_release(line);
    lines[pin - 1] = NULL;

    chip = chips[pin - 1];
    if (! chip) {
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
