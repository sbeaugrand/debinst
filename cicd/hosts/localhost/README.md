# Installation
```shell
vi playbook.yml +/Optional
make sudoers
make local
make extraroles
```

# Markdown

<details>
  <summary>Chromium</summary>

  https://github.com/md-reader/md-reader
</details>

<details>
  <summary>Firefox</summary>

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
      --back: black;
      --alt-link: #00aaaa;
      --alt-back: #222222;
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
</details>

<details>
  <summary>Mermaid</summary>

  ```sh
  sudo apt install npm
  cd ~/.local
  npm i @mermaid-js/mermaid-cli
  cd bin
  ln -s ../node_modules/.bin/mmdc
  ```
</details>

# Crypted partition

<details>
  <summary>Usage example</summary>

  ```shell
  sudo dd if=/dev/random of=/root/luksKey bs=512 count=8
  sudo cryptsetup luksAddKey /dev/sda3 /root/luksKey
  ansible-playbook ../../makefiles/includeroles.yml -e host=all -e list="['crypted']" -e dev=sda3 -e mnt=data
  sudo systemctl enable data.mount
  ```
</details>

<details>
  <summary>Disable</summary>

  ```sh
  sudo cryptsetup --test-passphrase open /dev/sda3
  sudo cryptsetup luksRemoveKey /dev/sda3 /root/luksKey
  sudo systemctl disable data.mount
  ```
</details>

<details>
  <summary>Re-enable</summary>

  ```sh
  sudo cryptsetup luksAddKey /dev/sda3 /root/luksKey
  sudo systemctl enable data.mount
  sudo systemctl start data
  ```
</details>

# owa-html5-notifications

<details>
  <summary>Chromium</summary>

  ```sh
  make extraroles EXTRAROLES="[\'notifications-owa\']"
  chromium  # Manage extensions => Developer mode => Load unpacked
  ```
</details>

<details>
  <summary>Firefox</summary>

  ```sh
  cd ../../makefiles/roles/notifications-owa/tasks/firefox
  zip -r -FS ~/.local/share/owa-html5-notifications.zip *
  firefox about:config  # xpinstall.signatures.required false
  firefox about:addons  # Install Add-on From File
  ```
</details>
