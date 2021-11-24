# ---------------------------------------------------------------------------- #
## \file pigpio.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import mraa
import time

OUTPUT = mraa.DIR_OUT

TXGPIOPIN = 15

class pulse:
    def __init__(self, gpio_on, gpio_off, delay):
        self.gpio_on = gpio_on
        self.gpio_off = gpio_off
        self.delay = delay

class pi:
    def __init__(self):
        self.gpio = mraa.Gpio(TXGPIOPIN)
        self.connected = True

    def wave_add_new(self):
        pass

    def set_mode(self, gpio, mode):
        self.gpio.dir(mode)

    def wave_add_generic(self, pulses):
        self.pulses = pulses

    def wave_create(self):
        return 0

    def wave_send_once(self, wave_id):
        for p in self.pulses:
            if p.gpio_on > 0:
                self.gpio.write(1)
            else:
                self.gpio.write(0)
            time.sleep(p.delay / 1000000)

    def wave_tx_busy(self):
        return False

    def wave_delete(self, wave_id):
        self.pulses = []

    def stop(self):
        self.connected = False
