#include "ssd1306.hpp"

#define DEVICE_ADDRESS 0x3C
#define BUS_NUMBER 0x1

int main(int argc, char* argv[])
{
    if (argc != 4 && argc != 1) {
        return 1;
    }

    upm::SSD1306 lcd(BUS_NUMBER, DEVICE_ADDRESS);
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
