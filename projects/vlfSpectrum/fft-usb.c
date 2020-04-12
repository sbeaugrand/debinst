/******************************************************************************!
 * \file fft-usb.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdlib.h>
#include <libusb-1.0/libusb.h>
#include "debug.h"

#define VENDOR_ID 0x4242
#define DEVICE_ID 0x0002
#define EP_ADDR (LIBUSB_ENDPOINT_IN | 1)  // lsusb -v | grep bEndpointAddress
#define BUFF_SIZE 8  // wMaxPacketSize

struct libusb_device_handle* gDev = NULL;
struct libusb_transfer* gTransfer = NULL;
unsigned char* gTransferBuff = NULL;
uint16_t* gBuff;
uint32_t gSize;

/******************************************************************************!
 * \fn sockQuit
 ******************************************************************************/
void sockQuit()
{
    if (gTransfer != NULL) {
        libusb_cancel_transfer(gTransfer);
        libusb_free_transfer(gTransfer);
        gTransfer = NULL;
    }
    if (gTransferBuff != NULL) {
        free(gTransferBuff);
        gTransferBuff = NULL;
    }
    if (gDev != NULL) {
        libusb_release_interface(gDev, 0);
        libusb_close(gDev);
        gDev = NULL;
        libusb_exit(NULL);
    }
}

/******************************************************************************!
 * \fn status
 ******************************************************************************/
void status(const char* str, int code)
{
    if (code < 0) {
        ERROR("%s (err=%d)\n", str, code);
        sockQuit();
        exit(EXIT_FAILURE);
    } else {
        DEBUG("%s: %d", str, code);
    }
}

/******************************************************************************!
 * \fn callback
 ******************************************************************************/
void callback(struct libusb_transfer* transfer)
{
    static struct timeval tv;
    static time_t offset = 0;
    static uint32_t uint4;

    if (gettimeofday(&tv, NULL) < 0) {
        ERRNO("gettimeofday");
        exit(EXIT_FAILURE);
    }
    if (offset == 0) {
        offset = tv.tv_sec;
    }
    gBuff[gSize++] = (uint16_t) (tv.tv_sec - offset);
    uint4 = (uint32_t) tv.tv_usec;
    gBuff[gSize++] = uint4 >> 16;
    gBuff[gSize++] = uint4 & 0xFFFFu;
    gBuff[gSize++] = (transfer->buffer[0] << 8) + transfer->buffer[0];

    libusb_submit_transfer(transfer);
}

/******************************************************************************!
 * \fn sockInit
 ******************************************************************************/
void sockInit(int argc, char* argv[])
{
    int r;

    if (argc != 3) {
        ERROR("Usage: %s <frequence-min> <frequence-max>", argv[0]);
        exit(EXIT_FAILURE);
    }

    r = libusb_init(NULL);
    status("libusb_init", r);

    gDev = libusb_open_device_with_vid_pid(NULL, VENDOR_ID, DEVICE_ID);
    status("libusb_open_device_with_vid_pid", (gDev == NULL) ? -1 : 0);

    if (libusb_kernel_driver_active(gDev, 0)) {
        r = libusb_detach_kernel_driver(gDev, 0);
        status("libusb_detach_kernel_driver", r);
    }

    r = libusb_claim_interface(gDev, 0);
    status("libusb_claim_interface", r);

    gTransfer = libusb_alloc_transfer(0);
    status("libusb_alloc_transfer", (gTransfer == NULL) ? -1 : 0);

    gTransferBuff = (unsigned char*) malloc(BUFF_SIZE);

    libusb_fill_interrupt_transfer(gTransfer, gDev, EP_ADDR,
                                   gTransferBuff, BUFF_SIZE, callback, NULL, 0);

    r = libusb_submit_transfer(gTransfer);
    status("libusb_submit_transfer", r);
}

/******************************************************************************!
 * \fn sockRead
 ******************************************************************************/
ssize_t sockRead(unsigned char* buff, size_t size)
{
    static uint32_t count = 0;
    int r;

    gBuff = (uint16_t*) buff;
    size = size >> 1;
    gBuff[0] = count >> 16;
    gBuff[1] = count & 0xFFFFu;
    gSize = 4;

    while (gSize != size) {
        r = libusb_handle_events(NULL);
        if (r < 0) {
            status("libusb_handle_events", r);
        }
    }
    gSize -= 4;
    gSize = gSize << 1;
    gBuff[2] = gSize >> 16;
    gBuff[3] = gSize & 0xFFFFu;
    ++count;
    return gSize;
}
