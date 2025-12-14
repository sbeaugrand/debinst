/******************************************************************************!
 * \file firmware.c
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright GNU GPLv2 or GNU GPLv3, or proprietary
 * \note Modified from :
 *       http://yveslebrac.blogspot.com/2008/10/cheapest-dual-trace-scope-in-galaxy.html
 *       http://www.reality.be/files/firmwarev3.zip
 *       Based on :
 *       https://github.com/obdev/v-usb
 ******************************************************************************/
/* Project: Data input based on AVR USB driver with TINY45
 * V3: 2 inputs ADC2/PB4 ADC3/PB3, pas de switch, led sur PB1 (on=0)
 * Author: Jacques Lepot
 * Creation Date: 2008-04-19
 * Copyright: (c) 2008 by Jacques Lepot
 * License: Proprietary, free under certain conditions.
 */
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/eeprom.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <util/delay.h>
#include "usbdrv.h"
#include "wiring.h"

uchar reportBuffer[5];  // buffer for HID reports, type game cntrler
uchar idleRate;  // in 4 ms units

static uchar adchanel;
static int adcval1;
static int adcval2;

PROGMEM const char usbHidReportDescriptor[
    USB_CFG_HID_REPORT_DESCRIPTOR_LENGTH] = {  /* USB report descriptor */
    0x05, 0x01,  // USAGE_PAGE (Generic Desktop = 01)
    0x09, 0x05,            // USAGE (Game Pad = 05)
    0xa1, 0x01,            // COLLECTION (Application)
    0x09, 0x01,            //   USAGE (Pointer)
    0xa1, 0x00,            //   COLLECTION (Physical)
    0x09, 0x30,            //     USAGE (X)
    0x09, 0x31,            //     USAGE (Y)
    0x15, 0x00,            //   LOGICAL_MINIMUM (0)
    0x26, 0xff, 0x00,      //     LOGICAL_MAXIMUM (255)
    0x75, 0x08,            //   REPORT_SIZE (8bits)
    0x95, 0x04,            //   REPORT_COUNT (2)
    0x81, 0x02,            //   INPUT (Data,Var,Abs)
    0xc0,                  // END_COLLECTION

    0x05, 0x09,            // USAGE_PAGE (Button)
    0x19, 0x01,            //   USAGE_MINIMUM (Button 1)
    0x29, 0x08,            //   USAGE_MAXIMUM (Button 8)
    0x15, 0x00,            //   LOGICAL_MINIMUM (0)
    0x25, 0x01,            //   LOGICAL_MAXIMUM (1)
    0x75, 0x01,            // REPORT_SIZE (1bit)
    0x95, 0x08,            // REPORT_COUNT (8)
    0x81, 0x02,            // INPUT (Data,Var,Abs)
    0xc0                   // END_COLLECTION
};

/******************************************************************************!
 * \fn buildReport
 ******************************************************************************/
void buildReport()
{
    reportBuffer[0] = adcval1 >> 8;
    reportBuffer[1] = adcval1;
    reportBuffer[2] = adcval2 >> 8;
    reportBuffer[3] = adcval2;
    reportBuffer[4] = 0x01;
}

/******************************************************************************!
 * \fn adcPoll
 ******************************************************************************/
static void adcPoll()
{
    int adc;
    if (adchanel) {
        adc = analogRead(PINB4);
    } else {
        adc = analogRead(PINB3);
    }
    if (adc != -1) {
        if (adchanel) {
            adcval1 = adc + adc + (adc >> 1);  // adc * 2.5 for output in mV
        } else {
            adcval2 = adc + adc + (adc >> 1);  // adc * 2.5 for output in mV
        }
        adchanel = ! adchanel;
    }
}

/******************************************************************************!
 * \fn usbEventResetReady
 ******************************************************************************/
void usbEventResetReady()
{
    calibrateOscillator();
    eeprom_write_byte(0, OSCCAL);  // store the calibrated value in EEPROM
}

/******************************************************************************!
 * \fn setup
 ******************************************************************************/
static void
setup()
{
    uchar i;
    uchar calibrationValue;

    calibrationValue = eeprom_read_byte(0);  // calibration value from last time
    if (calibrationValue != 0xff) {
        OSCCAL = calibrationValue;
    }
    usbDeviceDisconnect();
    for (i = 0; i < 20; i++) {  // 300 ms disconnect
        _delay_ms(15);
    }
    usbDeviceConnect();
    digitalInit(PINB1, OUTPUT);
    wdt_enable(WDTO_1S);
    analogInit();
    usbInit();
    sei();
    digitalWrite(PINB1, 0);
 }

/******************************************************************************!
 * \fn loop
 ******************************************************************************/
void loop()
{
    wdt_reset();
    usbPoll();
    if (usbInterruptIsReady()) {
        buildReport();
        usbSetInterrupt(reportBuffer, sizeof(reportBuffer));
    }
    adcPoll();
 }

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int main()
{
    setup();
    for (;;) {
        loop();
    }
    return 0;
}
