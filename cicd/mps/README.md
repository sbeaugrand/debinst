# Client state diagram
```mermaid
stateDiagram
    direction LR
    [*] --> Normal
    Normal --> Normal: setup / ok / up / down / right
    Normal --> Album: left
    Album --> Normal: ok
    Album --> Album: up / down
    Album --> Artist: left
    Artist --> Album: setup
    Artist --> Artist: letter
```

# Screensaver state diagram
```mermaid
stateDiagram
    direction LR
    [*] --> Normal
    Normal --> Menu: ok
    Menu --> Normal: ok = cancel
    Menu --> Normal: right = /usr/bin/rtc
	Menu --> [*]: up = reboot / down = halt
    Menu --> Date: left
    Date --> Date: dir
    Date --> Hour: ok
    Hour --> Hour: dir
    Hour --> Normal: ok
```
