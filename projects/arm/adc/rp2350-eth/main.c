/******************************************************************************!
 * \file main.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note https://github.com/raspberrypi/
 *       pico-examples/blob/master/adc/hello_adc/hello_adc.c
 *
 *  t3highlight main.c
 *  sudo apt install picolibc-arm-none-eabi
 *  cd ../../pico-sdk
 *  git submodule update --init
 *  cd -
 *  mkdir -p build && cd build
 *  cmake .. -DPICO_SDK_PATH=../../../pico-sdk -DPICO_BOARD=waveshare_rp2350_eth
 *  make -j`nproc`
 *  # BOOT+RESET -RESET -BOOT
 *  cp main.uf2 /media/$USER/RP2350/
 *  # Static IP 192.168.1.10
 *  ../client.py
 *  03a5  0.752V  5866Hz
 *  03ab  0.757V  5756Hz
 *  03a8  0.754V  5742Hz
 *  03aa  0.756V  5835Hz
 *  03aa  0.756V  5742Hz
 *  03ab  0.757V  5744Hz
 *  03aa  0.756V  5792Hz
 *  03aa  0.756V  5762Hz
 *  03a5  0.752V  5796Hz
 *  03ac  0.757V  5774Hz
 ******************************************************************************/
#include <hardware/adc.h>
#include "CH9120_Test.h"

extern UCHAR CH9120_Mode;

int
main()
{
    uint16_t r;

    CH9120_Mode = UDP_SERVER;
    CH9120_init();

    adc_init();
    adc_gpio_init(26);
    adc_select_input(0);

    for (;;) {
        r = adc_read();
        if (uart_is_writable(UART_ID1)) {
            uart_putc(UART_ID1, r >> 8);
            uart_putc(UART_ID1, r & 0xff);
        }
    }
}
