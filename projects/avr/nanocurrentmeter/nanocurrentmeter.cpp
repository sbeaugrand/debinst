/******************************************************************************!
 * \file nanocurrentmeter.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note http://www.technoblogy.com/show?2S67
 *       https://www.microchip.com/en-us/product/ATtiny85#Documentation
 ******************************************************************************/
#include <Arduino.h>

#define PIN_ADC PIN_PB2
#define PIN_LED PIN_PB4

void
setup()
{
    pinMode(PIN_LED, OUTPUT);
}

void
loop()
{
    pinMode(PIN_ADC, OUTPUT);
    digitalWrite(PIN_ADC, HIGH);
    delay(500);
    pinMode(PIN_ADC, INPUT);
    unsigned long Time;
    unsigned long Start = millis();
    int Initial = analogRead(PIN_ADC);
    int Target = (Initial * 29) / 41;
    do {
        Time = millis() - Start;
    } while (analogRead(PIN_ADC) > Target && Time < 100000);
    digitalWrite(PIN_LED, HIGH);
    Serial.begin(9600);
    Serial.println(1732868 / Time);
    Serial.end();
    digitalWrite(PIN_LED, LOW);
}
