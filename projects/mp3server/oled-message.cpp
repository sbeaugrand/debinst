#include "ssd1306.hpp"

#define DEVICE_ADDRESS 0x3C
#define BUS_NUMBER 0x1

int main(int argc, char* argv[])
{
    if (argc != 2) {
        return 1;
    }
    upm::SSD1306 lcd(BUS_NUMBER, DEVICE_ADDRESS);
    lcd.clear();
    lcd.setCursor(4, 0);
    lcd.write(argv[1]);
    return 0;
}
