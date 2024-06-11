# Client state diagram
```mermaid
stateDiagram
    direction LR
    [*] --> Normal
    Normal --> Normal: setup/ok/up/down/right
    Normal --> Album: left
    Album --> Normal: ok
    Album --> Album: up/down
    Album --> Artist: left
    Artist --> Album: setup
    Artist --> Artist: letter
```

# Screensaver state diagram
```mermaid
stateDiagram
    direction LR
    [*] --> Normal
    Normal --> Hour: right
	Normal --> [*]: stop
    Hour --> Hour: dir
    Hour --> Date: ok
    Date --> Normal: ok
    Date --> Date: dir
```
