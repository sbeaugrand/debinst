# Test stepper direction
```
; Use Relative Coordinates
G91
; Coordinated Movement X Y Z E
G1 X10
G1 E1
; Use Absolute Coordinates
G90
; Report current position
M114
; Set current position to coordinates given
G92 X0 Y0 Z0 E0
```

# Change steps per unit
```
; Print the current settings (in memory)
M503
; Set steps per unit
M92 Z4000 E550
; Test Z feedrate in units/min
G1 Z1 F180
G1 Z2 F120
; Set maximum feedrate in units/sec
M203 Z2
; Store parameters in EEPROM
M500
```

# Test extruder temperature
```
; Report current temperatures
M105
; Set extruder target temp
M104 S180
M105
M104 S0
M105
```

# Test bed temperature
```
; Report current temperatures
M105
; Set bed target temp
M140 S60
M105
M140 S0
M105
```
