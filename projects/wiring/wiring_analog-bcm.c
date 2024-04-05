/******************************************************************************!
 * \file wiring_analog-bcm.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <bcm2835.h>

/******************************************************************************!
 * \fn analogInit
 ******************************************************************************/
int
analogInit()
{
    if (! bcm2835_init()) {
        return 0;
    }
    bcm2835_spi_begin();
    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);  // Par defaut
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);  // Par defaut
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64);  // 64 ~= 4 MHz
    bcm2835_spi_chipSelect(BCM2835_SPI_CS1);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS1, LOW);
    return 1;
}

/******************************************************************************!
 * \fn analogRead
 ******************************************************************************/
int
analogRead(uint8_t pin)
{
    static uint8_t mosi[2] = {
        0x60, 0x00
    };
    static uint8_t miso[2] = {
        0
    };
    pin = pin;

    bcm2835_spi_transfernb((char*) mosi, (char*) miso, 2);

    return ((miso[0] & 3) << 8) | miso[1];
}

/******************************************************************************!
 * \fn analogQuit
 ******************************************************************************/
void
analogQuit()
{
    bcm2835_spi_end();
    bcm2835_close();
}
