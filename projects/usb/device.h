/******************************************************************************!
 * \file device.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef _USB_DEVICE_H_
#define _USB_DEVICE_H_

#include <libusb-1.0/libusb.h>

typedef unsigned char UChar;

namespace USB {

class Device
{
public:
    Device();
    ~Device();
    void open(uint16_t vendor_id, uint16_t device_id);
    void close();
    void submit(unsigned char endpoint, int length,
                void (* callback)(struct libusb_transfer* transfer));
    void submit(struct libusb_transfer* transfer) const;

private:
    void status(const char* str, int code);

    struct libusb_device_handle* mDev;
    struct libusb_transfer* mTransfer;
    UChar* mBuff;
};

}  // namespace USB

#endif
