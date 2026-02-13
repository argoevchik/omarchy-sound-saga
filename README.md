# omarchy-sound-saga
> [!CAUTION]
> Current state: WIP
> NOTE: This script was developed and maintained for personal use, for simplifying installation of new system and updating
> Thanks to guys who made this possible
> https://github.com/nadimkobeissi/16iax10h-linux-sound-saga

## Usage
  + install dependencies
  > for archlinux:
  ```bash
sudo pacman -Sy base-devel linux-headers nvidia-open-dkms bc cargo alsa-utils
```
  + run and follow the instructions
```bash
  sudo bash archlinux-saga.sh
  ```
  + for limine boot loader add this to cmdline in limine.conf
  > snd_intel_dspcfg.dsp_driver=3
  + reboot
  + run and follow the instructions
```bash 
bash postfix.sh
```
