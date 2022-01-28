# Example 1
```
cd ~/install/debinst/latex/cal
make gcode

cat cadran.nc | ~/install/debinst/projects/gcodesender/gcodesender.py
```

# Example 2
```
cd ~/install/debinst/latex/tock
make gcode

cat tock4.nc | ~/install/debinst/projects/gcodesender/gcodesender.py
cat tock6.nc | ~/install/debinst/projects/gcodesender/gcodesender.py
```

# Example 3
```
identify photo.jpg
convert photo.jpg -resize 840x resized.png  # x840 when landscape
~/install/debinst/projects/gcodesender/img1foreground.py resized.png foreground.png
gimp foreground.png  # remove remaining background
~/install/debinst/projects/gcodesender/img2contrast.py foreground.png contrast.png 80 255 48 128 0 0
~/install/debinst/projects/gcodesender/img3gcode.py contrast.png 190 4 5 300 500 240 3600 >photo.nc

cat photo.nc | ~/install/debinst/projects/gcodesender/gcodesender.py
```

# Tests
```
make test
make itest
```
