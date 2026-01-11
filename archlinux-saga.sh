#!/bin/bash

echo "THE PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION."
read -p "Press [Enter] key to continue..." hwX

# Downoading solution
# git clone https://github.com/nadimkobeissi/16iax10h-linux-sound-saga.git

setopt() {
  # look for/create parametr in file and assigns value to it
  # syntax setopt <file> <parametr> <value>
  file=$1
  key=$2
  val=$3

  if grep -q "^$key=" "$file"; then
    sed -i "s/^$key=.*/$key=$val/" "$file"
  else
    echo "$key=$val" >>"$file"
  fi
  echo "$key=$val option set"
}

current_kernel_version="linux-$(sed 's+-.*++g' <<<"$(uname -r)")"
current_kernel_tarball="$current_kernel_version.tar.xz"
patch_name="16iax10h-audio-$current_kernel_version.patch"

if [ -s "fix/patches/$patch_name" ]; then
  echo "patch version match"
else
  echo "Kernel: $current_kernel_version"
  echo "patch_name: $patch_name"
  echo "tarball: $current_kernel_tarball"
  echo ""
  echo "Exact patch match was not found"
  echo "Press [Ctrl+C] key to exit"
  read -p "Press [Enter] key to continue..." tmp
  patch_name="16iax10h-audio-linux-6.18.patch"
  echo "fallback to patch name:"
  echo "$patch_name"
fi
echo "Kernel: $current_kernel_version"
echo "patch_name: $patch_name"
echo "tarball: $current_kernel_tarball"
read -p "Press [Enter] key to continue..." tmp

echo "copy firmware"
cp -f fix/firmware/aw88399_acf.bin /lib/firmware/aw88399_acf.bin
read -p "Press [Enter] key to continue..." tmp

if [ -s $current_kernel_tarball ]; then
  rm -rf $current_kernel_tarball
fi
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/$current_kernel_tarball

echo "linux kernel downloaded"

if [ -s $current_kernel_version ]; then
  rm -rf $current_kernel_version
fi

tar -xf $current_kernel_tarball

cp fix/patches/$patch_name $current_kernel_version/$patch_name

cd $current_kernel_version
patch -p1 <$patch_name

echo "Look, there should be 10 patches"
read -p "Press [Enter] key to continue..." tmp

cat /proc/config.gz | gunzip >.config

setopt .config CONFIG_SND_HDA_SCODEC_AW88399 m
setopt .config CONFIG_SND_HDA_SCODEC_AW88399_I2C m
setopt .config CONFIG_SND_SOC_AW88399 m
setopt .config CONFIG_SND_SOC_SOF_INTEL_TOPLEVEL y
setopt .config CONFIG_SND_SOC_SOF_INTEL_COMMON m
setopt .config CONFIG_SND_SOC_SOF_INTEL_MTL m
setopt .config CONFIG_SND_SOC_SOF_INTEL_LNL m

echo "7 options should be set"
read -p "Press [Enter] key to continue..." tmp

make -j24
make -j24 modules
sudo make -j24 modules_install

echo "look if kernel compiled"
read -p "Press [Enter] key to continue..." tmp
sudo cp -f arch/x86/boot/bzImage /boot/vmlinuz-linux-16iax10h-audio

sudo cp /etc/mkinitcpio.d/linux.preset /etc/mkinitcpio.d/linux-16iax10h-audio.preset

mkinitcpio_preset=/etc/mkinitcpio.d/linux-16iax10h-audio.preset
setopt $mkinitcpio_preset ALL_kver ""/boot/vmlinuz-linux-16iax10h-audio""
setopt $mkinitcpio_preset PRESETS "('default')"
setopt $mkinitcpio_preset default_image ""/boot/initramfs-linux-16iax10h-audio.img""

# NOTE:
# sudo limine-entry-tool --add new-linux-16iax10h-audio /boot/cryptichashshit/linux-16iax10h-audio/omarchy_linux.efi /boot/cryptichashshit/linux-16iax10h-audio/vmlinuz-linux-16iax10h-audio "" --comment "Linux for Lenovo Legion 7 16iax10h with Audio Support"
# sudo limine-entry-tool --add new-linux-16iax10h-audio /boot/cryptichashshit/linux-16iax10h-audio/initramfs-linux-16iax10h-audio.img /boot/cryptichashshit/linux-16iax10h-audio/vmlinuz-linux-16iax10h-audio "" --comment "Linux for Lenovo Legion 7 16iax10h with Audio Support"
