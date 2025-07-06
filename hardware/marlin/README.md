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

# PrusaSlicer config

## install
```sh
colordiff -y -W 160 --suppress-common-lines PrusaSlicer-Prusa_i3_Rework/filament/Default_Marlin2.ini PrusaSlicer-Prusa_i3_Rework/filament/Prusa_i3_Rework.ini
colordiff -y -W 160 --suppress-common-lines PrusaSlicer-Prusa_i3_Rework/printer/Default_Marlin2.ini PrusaSlicer-Prusa_i3_Rework/printer/Prusa_i3_Rework.ini
colordiff -y -W 160 --suppress-common-lines PrusaSlicer-Prusa_i3_Rework/print/Default_Marlin2.ini PrusaSlicer-Prusa_i3_Rework/print/Prusa_i3_Rework.ini
cp -auv PrusaSlicer-Prusa_i3_Rework/filament/* ~/.config/PrusaSlicer/filament/
cp -auv PrusaSlicer-Prusa_i3_Rework/printer/* ~/.config/PrusaSlicer/printer/
cp -auv PrusaSlicer-Prusa_i3_Rework/print/* ~/.config/PrusaSlicer/print/
```

## Recreate Default_Marlin2
Configuration Wizard => Custom Printer => Name Default_Marlin2 => Firmware Marlin 2 => Finish

## Update Prusa_i3_Rework
Print Settings => Save current Print Settings

Filament Settings => Save current Filament Settings

Printer Settings => Save current Printer Settings

## Save
```sh
colordiff -y -W 160 --suppress-common-lines ~/.config/PrusaSlicer/filament/Prusa_i3_Rework.ini PrusaSlicer-Prusa_i3_Rework/filament/Prusa_i3_Rework.ini
colordiff -y -W 160 --suppress-common-lines ~/.config/PrusaSlicer/printer/Prusa_i3_Rework.ini PrusaSlicer-Prusa_i3_Rework/printer/Prusa_i3_Rework.ini
colordiff -y -W 160 --suppress-common-lines ~/.config/PrusaSlicer/print/Prusa_i3_Rework.ini PrusaSlicer-Prusa_i3_Rework/print/Prusa_i3_Rework.ini
cp -auv ~/.config/PrusaSlicer/filament/* PrusaSlicer-Prusa_i3_Rework/filament/
cp -auv ~/.config/PrusaSlicer/printer/* PrusaSlicer-Prusa_i3_Rework/printer/
cp -auv ~/.config/PrusaSlicer/print/* PrusaSlicer-Prusa_i3_Rework/print/
```
