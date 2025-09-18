# Example 1
```sh
cd ~/install/debinst/latex/cal
make gcode

cat cadran.nc | ~/install/debinst/projects/gcodesender/gcodesender.py
```

# Example 2
```sh
cd ~/install/debinst/latex/tock
make gcode

cat tock4.nc | ~/install/debinst/projects/gcodesender/gcodesender.py
cat tock6.nc | ~/install/debinst/projects/gcodesender/gcodesender.py
```

# Example 3
```sh
identify photo.jpg
convert photo.jpg -resize 840x resized.png  # x840 when landscape
~/install/debinst/projects/gcodesender/img1foreground.py resized.png foreground.png
gimp foreground.png  # remove remaining background
~/install/debinst/projects/gcodesender/img2contrast.py foreground.png contrast.png 80 255 48 128 0 0
~/install/debinst/projects/gcodesender/img3gcode.py contrast.png 190 4 5 300 500 240 3600 >photo.nc

cat photo.nc | ~/install/debinst/projects/gcodesender/gcodesender.py
```

# Tests
```sh
make test
make itest
```

# Z axis test example with M8 screw and 16 microsteps
```
$$
$102=2560 (200x16/1.25 steps/mm)
$112=120 (mm/min)
G91 (relative coordinates)
G1 Z1 F120
```
