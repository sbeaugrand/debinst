/******************************************************************************!
 * \file wiring_digital-sysfs.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "wiring.h"

/******************************************************************************!
 * \fn digitalInit
 ******************************************************************************/
int digitalInit(uint8_t pin, uint8_t mode)
{
    char buf[33];
    int fd;

    if ((fd = open("/sys/class/gpio/export", O_WRONLY)) == -1) {
        return GPIO_ERROR_OPEN;
    }
    sprintf(buf, "%u", pin);
    if (write(fd, buf, strlen(buf)) == -1) {
        //return GPIO_ERROR_WRITE;
    }
    if (close(fd) == -1) {
        return GPIO_ERROR_CLOSE;
    }
    if (snprintf(buf, 33, "/sys/class/gpio/gpio%u/direction", pin) >= 33) {
        return GPIO_ERROR_OPEN;
    }
    if ((fd = open(buf, O_WRONLY)) == -1) {
        return GPIO_ERROR_OPEN;
    }
    if (mode == INPUT) {
        if (write(fd, "in", 2) == -1) {
            return GPIO_ERROR_WRITE;
        }
    } else {
        if (write(fd, "out", 3) == -1) {
            return GPIO_ERROR_WRITE;
        }
    }
    if (close(fd) == -1) {
        return GPIO_ERROR_CLOSE;
    }
    return 0;
}

/******************************************************************************!
 * \fn digitalRead
 ******************************************************************************/
int digitalRead(uint8_t pin)
{
    static char buf[29];
    int fd;

    if (snprintf(buf, 29, "/sys/class/gpio/gpio%u/value", pin) >= 29) {
        return GPIO_ERROR_OPEN;
    }
    if ((fd = open(buf, O_RDONLY)) == -1) {
        return GPIO_ERROR_OPEN;
    }
    buf[0] = '\0';
    buf[1] = '\0';
    buf[2] = '\0';
    if (read(fd, buf, 2) == -1) {
        return GPIO_ERROR_READ;
    }
    if (close(fd) == -1) {
        return GPIO_ERROR_CLOSE;
    }
    return *buf - '0';
}

/******************************************************************************!
 * \fn digitalWrite
 ******************************************************************************/
void digitalWrite(uint8_t pin, uint8_t val)
{
    static char buf[29];
    int fd;

    if (snprintf(buf, 29, "/sys/class/gpio/gpio%u/value", pin) >= 29) {
        return;
    }
    if ((fd = open(buf, O_WRONLY)) == -1) {
        return;
    }
    sprintf(buf, "%u", val);
    if (write(fd, buf, 1) == -1) {
        return;
    }
    if (close(fd) == -1) {
        return;
    }
}

/******************************************************************************!
 * \fn digitalQuit
 ******************************************************************************/
int digitalQuit(uint8_t pin)
{
    char buf[4];
    int fd;

    if ((fd = open("/sys/class/gpio/unexport", O_WRONLY)) == -1) {
        return GPIO_ERROR_OPEN;
    }
    sprintf(buf, "%u", pin);
    if (write(fd, buf, strlen(buf)) == -1) {
        return GPIO_ERROR_WRITE;
    }
    if (close(fd) == -1) {
        return GPIO_ERROR_CLOSE;
    }
    return 0;
}
