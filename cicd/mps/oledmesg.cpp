/******************************************************************************!
 * \file oled-message.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "upm/ssd1306.hpp"

#define DEVICE_ADDRESS 0x3C

int
main(int argc, char** argv)
{
    if (argc != 4 &&
        argc != 1) {
        return 1;
    }

    upm::SSD1306* oled;
    try {
        oled = new upm::SSD1306(0, DEVICE_ADDRESS);
    } catch (...) {
        oled = new upm::SSD1306(1, DEVICE_ADDRESS);
    }
    oled->clear();

    if (argc == 1) {
        return 0;
    }

    int x = atoi(argv[2]);
    int y = atoi(argv[3]);
    oled->dim(true);
    oled->setCursor(y, x);
    oled->write(argv[1]);
    return 0;
}
