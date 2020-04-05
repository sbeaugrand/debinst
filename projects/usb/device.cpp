/******************************************************************************!
 * \file device.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "device.h"

namespace USB {

/******************************************************************************!
 * \fn Device
 ******************************************************************************/
Device::Device() :
    mDev(NULL),
    mTransfer(NULL),
    mBuff(NULL)
{
}

/******************************************************************************!
 * \fn ~Device
 ******************************************************************************/
Device::~Device()
{
    this->close();
}

/******************************************************************************!
 * \fn open
 ******************************************************************************/
void Device::open(uint16_t vendor_id, uint16_t device_id)
{
    int r = libusb_init(NULL);
    this->status("libusb_init", r);

    mDev = libusb_open_device_with_vid_pid(NULL, vendor_id, device_id);
    this->status("libusb_open_device_with_vid_pid", (mDev == NULL) ? -1 : 0);

    if (libusb_kernel_driver_active(mDev, 0)) {
        r = libusb_detach_kernel_driver(mDev, 0);
        this->status("libusb_detach_kernel_driver", r);
    }

    r = libusb_claim_interface(mDev, 0);
    this->status("libusb_claim_interface", r);
}

/******************************************************************************!
 * \fn close
 ******************************************************************************/
void Device::close()
{
    if (mTransfer != NULL) {
        libusb_cancel_transfer(mTransfer);
        libusb_free_transfer(mTransfer);
        mTransfer = NULL;
    }
    if (mBuff != NULL) {
        delete[] mBuff;
        mBuff = NULL;
    }
    if (mDev != NULL) {
        libusb_release_interface(mDev, 0);
        libusb_close(mDev);
        mDev = NULL;
        libusb_exit(NULL);
    }
}

/******************************************************************************!
 * \fn submit
 ******************************************************************************/
void Device::submit(UChar endpoint, int length,
                    void (* callback)(struct libusb_transfer* transfer))
{
    mTransfer = libusb_alloc_transfer(0);
    this->status("libusb_alloc_transfer", (mTransfer == NULL) ? -1 : 0);

    mBuff = new UChar[length];

    libusb_fill_interrupt_transfer(mTransfer, mDev, endpoint,
                                   mBuff, length, callback, NULL, 0);

    int r = libusb_submit_transfer(mTransfer);
    this->status("libusb_submit_transfer", r);
}

/******************************************************************************!
 * \fn submit
 ******************************************************************************/
void Device::submit(struct libusb_transfer* transfer) const
{
    libusb_submit_transfer(transfer);
}

/******************************************************************************!
 * \fn status
 ******************************************************************************/
void Device::status(const char* str, int code)
{
    if (code < 0) {
        fprintf(stderr, "error: %s (err=%d)\n", str, code);
        this->close();
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr, "%s: %d\n", str, code);
    }
}

}  // namespace USB
