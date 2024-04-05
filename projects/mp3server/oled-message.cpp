/******************************************************************************!
 * \file oled-message.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include "mraa/i2c.h"
#include "ssd1306.hpp"

#define DEVICE_ADDRESS 0x3C

int
main(int argc, char* argv[])
{
    if (argc != 4 && argc != 1) {
        return 1;
    }

    int bus = 0;
    mraa_i2c_context i2c = mraa_i2c_init(bus);
    if (i2c == NULL) {
        bus = 1;
        i2c = mraa_i2c_init(bus);
    }
    if (i2c == NULL) {
        return 1;
    }
    mraa_i2c_stop(i2c);

    upm::SSD1306 lcd(bus, DEVICE_ADDRESS);
    lcd.clear();
    if (argc == 1) {
        return 0;
    }

    int x = atoi(argv[2]);
    int y = atoi(argv[3]);
    lcd.dim(true);
    lcd.setCursor(y, x);
    lcd.write(argv[1]);
    return 0;
}
