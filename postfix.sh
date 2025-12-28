#!/bin/bash

echo "THE PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION."
read -p "Press [Enter] key to continue..." hwX

# touch /etc/modprobe.d/inteldsp.conf
# setopt /etc/modprobe.d/inteldsp.conf snd_intel_dspcfg.dsp_driver 3

cp -f fix/ucm2/HiFi-analog.conf /usr/share/alsa/ucm2/HDA/HiFi-analog.conf
cp -f fix/ucm2/HiFi-mic.conf /usr/share/alsa/ucm2/HDA/HiFi-mic.conf

alsaucm listcards

echo "look for something like"
echo "hw:X"
echo "LENOVO-83F5-LegionPro716IAX10H-LNVNB161216"
echo "enter correct X from hw:X line"
read -p "Press [Enter] key to continue..." hwX

alsaucm -c hw:$hwX reset
alsaucm -c hw:$hwX reload
systemctl --user restart pipewire pipewire-pulse wireplumber
amixer sset -c $hwX Master 100%
amixer sset -c $hwX Headphone 100%
amixer sset -c $hwX Speaker 100%
