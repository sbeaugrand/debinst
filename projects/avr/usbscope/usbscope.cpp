/******************************************************************************!
 * \file usbscope.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <libusb-1.0/libusb.h>
#include <sys/time.h>
#include <unistd.h>
#include <string.h>
#include "usb/device.h"
#include "x11Scope.h"

#define VENDOR_ID 0x4242
#define DEVICE_ID 0x0002
#define EP_ADDR (LIBUSB_ENDPOINT_IN | 1)  // lsusb -v | grep bEndpointAddress
#define BUFF_SIZE 8  // wMaxPacketSize

USB::Device* gDev = NULL;

FILE* gFile1 = NULL;
FILE* gFile2 = NULL;

X11::Callback* gLoop = NULL;
X11::Scope* gScope = NULL;

/******************************************************************************!
 * \fn closeAll
 ******************************************************************************/
void
closeAll()
{
    if (gScope != NULL) {
        delete gScope;
    }
    if (gLoop != NULL) {
        delete gLoop;
    }
    if (gFile1 != NULL) {
        fclose(gFile1);
    }
    if (gFile2 != NULL) {
        fclose(gFile2);
    }
    if (gDev != NULL) {
        gDev->close();
        delete gDev;
    }
}

/******************************************************************************!
 * \fn status
 ******************************************************************************/
void
status(const char* str, int code)
{
    if (code < 0) {
        fprintf(stderr, "error: %s (err=%d)\n", str, code);
        closeAll();
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr, "%s: %d\n", str, code);
    }
}

/******************************************************************************!
 * \fn callback
 ******************************************************************************/
void
callback(struct libusb_transfer* transfer)
{
    static struct timeval tv;
    static time_t tstart = 0;
    static suseconds_t ustart = -1;
    static double time;
    static double val1;
    static double val2;

    gettimeofday(&tv, NULL);
    if (tstart == 0) {
        tstart = tv.tv_sec;
        ustart = tv.tv_usec;
    }
    tv.tv_sec -= tstart;
    if (tv.tv_usec >= ustart) {
        tv.tv_usec -= ustart;
    } else {
        tv.tv_sec -= 1;
        tv.tv_usec += 1000000 - ustart;
    }
    time = tv.tv_sec + tv.tv_usec / 1000000.0;
    // 0.92 :
    // http://www.reality.be/elo/labos3/files/usb-scope.zip
    // vi usb-scope/UsbApp/usbscope.cs +105
    val1 = ((transfer->buffer[0] << 8) + transfer->buffer[1]) * 0.00092;
    fprintf(gFile1, "%ld.%06ld %.3f\n", tv.tv_sec, tv.tv_usec, val1);
    if (gFile2 != NULL) {
        val2 = ((transfer->buffer[2] << 8) + transfer->buffer[3]) * 0.00092;
        fprintf(gFile2, "%ld.%06ld %.3f\n", tv.tv_sec, tv.tv_usec, val2);
    }

    if (gFile2 != NULL) {
        gScope->drawPoints(time, val1, val2);
    } else {
        gScope->drawPoints(time, val1);
    }

    gDev->submit(transfer);
}

/******************************************************************************!
 * \class LoopCallback
 ******************************************************************************/
class LoopCallback : public X11::Callback
{
public:
    int loop(const X11::Event*)
    {
        int r = libusb_handle_events(NULL);
        if (r < 0) {
            status("libusb_handle_events", r);
        }
        return 0;
    }
};

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int argc, char** argv)
{
    if (argc != 2 && argc != 3) {
        printf("Usage: %s <file> [<file>]\n", argv[0]);
        return EXIT_FAILURE;
    }

    gDev = new USB::Device();
    gDev->open(VENDOR_ID, DEVICE_ID);
    gDev->submit(EP_ADDR, BUFF_SIZE, callback);

    gFile1 = fopen(argv[1], "w");
    status("fopen 1", (gFile1 == NULL) ? -1 : 0);
    if (argc == 3) {
        gFile2 = fopen(argv[2], "w");
        status("fopen 2", (gFile2 == NULL) ? -1 : 0);
    }

    gLoop = new LoopCallback;
    gScope = new X11::Scope;
    gScope->run(gLoop,
                (int (X11::Callback::*)(const X11::Event*))
                & LoopCallback::loop);

    closeAll();
    return EXIT_SUCCESS;
}
