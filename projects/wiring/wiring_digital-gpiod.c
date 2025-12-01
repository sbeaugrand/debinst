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
struct gpiod_line_request* gLines[GPIOD_MAX_PIN_COUNT] = { NULL };
int gOffsets[GPIOD_MAX_PIN_COUNT] = { 0 };

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
        if (gLines[i]) {
            fprintf(stderr, "%d ",
                    gpiod_line_request_get_value(gLines[i], gOffsets[i]));
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
    struct gpiod_chip* chip = NULL;
    struct gpiod_line_request* line;
    struct gpiod_line_info* info = NULL;
    struct gpiod_line_settings* settings = NULL;
    struct gpiod_line_config* cfg = NULL;
    char buf[6];
    int offset;
    int ret = 0;

    line = gLines[pin - 1];
    if (line) {
        offset = gOffsets[pin - 1];
    } else {
        if (snprintf(buf, 6, "pin%u", pin) >= 6) {
            ERROR("snprintf");
            ret = 1;
            goto finalize;
        }
        chip = gpiod_chip_open("/dev/gpiochip0");
        if (! chip) {
            ERRNO("gpiod_chip_open");
            ret = 2;
            goto finalize;
        }
        offset = gpiod_chip_get_line_offset_from_name(chip, buf);
        if (offset < 0) {
            ERRNO("gpiod_chip_get_line_offset_from_name");
            ret = 3;
            goto finalize;
        }
        info = gpiod_chip_get_line_info(chip, offset);
        if (! info) {
            ERRNO("gpiod_chip_get_line_info");
            ret = 4;
            goto finalize;
        }
        if (gpiod_line_info_is_used(info)) {
            ERROR("gpiod_line_info_is_used");
            ret = 5;
            goto finalize;
        }
    }

    settings = gpiod_line_settings_new();
    if (! settings) {
        ERRNO("gpiod_line_settings_new");
        ret = 6;
        goto finalize;
    }
    if (mode == INPUT) {
        if (gpiod_line_settings_set_direction(
                settings, GPIOD_LINE_DIRECTION_INPUT) < 0) {
            ERRNO("gpiod_line_settings_set_direction");
            ret = 7;
            goto finalize;
        }
    } else {
        if (gpiod_line_settings_set_direction(
                settings, GPIOD_LINE_DIRECTION_OUTPUT) < 0) {
            ERRNO("gpiod_line_settings_set_direction");
            ret = 7;
            goto finalize;
        }
    }
    cfg = gpiod_line_config_new();
    if (! cfg) {
        ERRNO("gpiod_line_config_new");
        ret = 8;
        goto finalize;
    }
    unsigned int offsets = offset;
    if (gpiod_line_config_add_line_settings(cfg, &offsets, 1, settings) < 0) {
        ERRNO("gpiod_line_config_add_line_settings");
        ret = 9;
        goto finalize;
    }

    if (chip) {
        line = gpiod_chip_request_lines(chip, NULL, cfg);
        if (! line) {
            ERRNO("gpiod_chip_request_lines");
            ret = 10;
            goto finalize;
        }
        gLines[pin - 1] = line;
        gOffsets[pin - 1] = offset;
    }

finalize:
    gpiod_line_config_free(cfg);
    gpiod_line_settings_free(settings);
    gpiod_line_info_free(info);
    gpiod_chip_close(chip);
    return ret;
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
    line = gLines[pin - 1];
    if (! line) {
        ERROR("line == NULL");
        return -1;
    }

    val = gpiod_line_request_get_value(line, gOffsets[pin - 1]);
    if (val < 0) {
        ERRNO("gpiod_line_request_get_value");
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
    line = gLines[pin - 1];
    if (! line) {
        ERROR("line == NULL");
        return;
    }

    gpiod_line_request_set_value(line, gOffsets[pin - 1], val);
}

/******************************************************************************!
 * \fn digitalQuit
 ******************************************************************************/
int
digitalQuit(uint8_t pin)
{
    struct gpiod_line_request* line;

#   ifndef NDEBUG
    debugValues();
#   endif
    line = gLines[pin - 1];
    if (! line) {
        ERROR("line == NULL");
        return 1;
    }
    gpiod_line_request_release(line);
    gLines[pin - 1] = NULL;

    return 0;
}
