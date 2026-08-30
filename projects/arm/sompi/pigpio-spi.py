# ---------------------------------------------------------------------------- #
## \file pigpio-spi.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
import spidev
import glob

BYTE_DURATION = 640  # 640 us/byte, spi 12500 Hz

class pulse:
    def __init__(self, gpio_on, gpio_off, delay):
        self.gpio_on = gpio_on
        self.gpio_off = gpio_off
        self.delay = delay

class pi:
    def __init__(self):
        files = glob.glob('/dev/spidev*')
        if len(files) != 1:
            print(f'error: {len(files)} devices')
            exit(1)
        self.spi = spidev.SpiDev()
        self.spi.open_path(files[0])
        self.spi.mode = 0
        self.spi.max_speed_hz = 8000000 // BYTE_DURATION
        self.connected = True

    def wave_add_new(self):
        pass

    def set_mode(self, gpio, mode):
        pass

    def wave_add_generic(self, pulses):
        self.pulses = pulses

    def wave_create(self):
        return 0

    def wave_send_once(self, wave_id):
        buff = []
        for p in self.pulses:
            if p.gpio_on > 0:
                buff.extend([0xff] * round(p.delay / BYTE_DURATION))
            else:
                buff.extend([0x00] * round(p.delay / BYTE_DURATION))
        self.spi.writebytes(buff)

    def wave_tx_busy(self):
        return False

    def wave_delete(self, wave_id):
        self.pulses = []

    def stop(self):
        self.connected = False
