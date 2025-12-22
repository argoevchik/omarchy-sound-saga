#!/bin/bash

# echo "Downoading solution"
# git clone https://github.com/nadimkobeissi/16iax10h-linux-sound-saga.git

copy firmware
cp -f fix/firmware/aw88399_acf.bin /lib/firmware/aw88399_acf.bin

current_kernel_version="linux-$(sed 's+-.*++g' <<< "$(uname -r)")"
current_kernel_tarball="$current_kernel_version.tar.xz"
patch_name="16iax10h-audio-$current_kernel_version.patch"

echo "$current_kernel_tarball"
read -p "Press [Enter] key to continue..." tmp

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/$current_kernel_tarball

echo "linux kernel downloaded"

tar -xf $current_kernel_tarball

cp fix/patches/$patch_name $current_kernel_version/$patch_name

cd $current_kernel_version
patch -p1 < $patch_name

echo "Look, there should be 10 patches"
read -p "Press [Enter] key to continue..." tmp

touch /etc/modprobe.d/inteldsp.conf
echo "snd_intel_dspcfg.dsp_driver=3" > /etc/modprobe.d/inteldsp.conf

cat /proc/config.gz | gunzip > .config


setopt() {
  file=$1
  key=$2
  val=$3

  if grep -q "^$key=" "$file"; then
    sed -i "s/^$key=.*/$key=$val/" "$file"
  else
    echo "$key=$val" >> "$file"
  fi
}
setopt .config CONFIG_SND_HDA_SCODEC_AW88399 m
setopt .config CONFIG_SND_HDA_SCODEC_AW88399_I2C m
setopt .config CONFIG_SND_SOC_AW88399 m
setopt .config CONFIG_SND_SOC_SOF_INTEL_TOPLEVEL y
setopt .config CONFIG_SND_SOC_SOF_INTEL_COMMON m
setopt .config CONFIG_SND_SOC_SOF_INTEL_MTL m
setopt .config CONFIG_SND_SOC_SOF_INTEL_LNL m

make -j24
make -j24 modules
sudo make -j24 modules_install
sudo cp -f arch/x86/boot/bzImage /boot/vmlinuz-linux-16iax10h-audio

# sudo limine-entry-tool --add new-linux-16iax10h-audio /boot/cryptichashshit/linux-16iax10h-audio/omarchy_linux.efi /boot/cryptichashshit/linux-16iax10h-audio/vmlinuz-linux-16iax10h-audio "" --comment "Linux for Lenovo Legion 7 16iax10h with Audio Support"
# sudo limine-entry-tool --add new-linux-16iax10h-audio /boot/cryptichashshit/linux-16iax10h-audio/initramfs-linux-16iax10h-audio.img /boot/cryptichashshit/linux-16iax10h-audio/vmlinuz-linux-16iax10h-audio "" --comment "Linux for Lenovo Legion 7 16iax10h with Audio Support"
