#include "ssd1306.hpp"

#define DEVICE_ADDRESS 0x3C
#define BUS_NUMBER 0x1

int main()
{
    upm::SSD1306 lcd(BUS_NUMBER, DEVICE_ADDRESS);
    lcd.clear();
    return 0;
}
