/******************************************************************************!
 * \file main.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note https://github.com/raspberrypi/pico-examples/tree/master/adc/hello_adc
 ******************************************************************************/
#include <hardware/adc.h>
#include "CH9120.h"

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
