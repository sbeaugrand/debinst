# Installation
```shell
make sudoers
make local
make extraroles
```

# Crypted partition

## Usage example
```shell
sudo dd if=/dev/random of=/root/luksKey bs=512 count=8
sudo cryptsetup luksAddKey /dev/sda3 /root/luksKey
ansible-playbook ../../makefiles/includeroles.yml \
  -e host=all -e list="['crypted']" -e dev=sda3 -e mnt=data
sudo systemctl enable data.mount
```

## Disable
```sh
sudo cryptsetup luksRemoveKey /dev/sda3 /root/luksKey
```

## Re-enable
```sh
sudo cryptsetup luksAddKey /dev/sda3 /root/luksKey
```

## Remove
```shell
sudo cryptsetup luksRemoveKey /dev/sda3 /root/luksKey
sudo systemctl disable data.mount
```

# Markdown

## Chromium
https://github.com/md-reader/md-reader

## Firefox
https://addons.mozilla.org/en-US/firefox/addon/markdown-viewer-webext
```sh
make extraroles EXTRAROLES="[\'mime-markdown\']"
firefox about:addons  # Preferences => Custom CSS
```
```css
@media screen {
  :root {
    background-color: black;
    --text: #aaaaaa;
    --link: #00cccc;
    --alt-link: #00aaaa;
  }
  h1 {
    color: #eeeeee;
  }
  h2 {
    color: #cccccc;
  }
  pre, code {
    background-color: #222222;
  }
}
```

# owa-html5-notifications

## Chromium
```sh
make extraroles EXTRAROLES="[\'notifications-owa\']"
chromium  # Manage extensions => Developer mode => Load unpacked
```

## Firefox
```sh
cd ../../makefiles/roles/notifications-owa/tasks/firefox
zip -r -FS ~/.local/share/owa-html5-notifications.zip *
firefox about:config  # xpinstall.signatures.required false
firefox about:addons  # Install Add-on From File
```
