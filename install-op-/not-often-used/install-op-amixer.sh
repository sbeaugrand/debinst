# ---------------------------------------------------------------------------- #
# amixer
# ---------------------------------------------------------------------------- #
amixer -q set Master 99% unmute
amixer -q set Headphone 99%,83% unmute
amixer -q set Speaker 0% mute
amixer -q set PCM 99% unmute
amixer -q set Mic 0% mute
amixer -q set 'Mic Boost' 0%
amixer -q set Beep 0% mute
amixer -q set 'Auto-Mute Mode' Enabled
amixer -q set Capture 0%
amixer -q set 'Internal Mic Boost' 0%
amixer -q set 'Loopback Mixing' Disabled
alsactl store
