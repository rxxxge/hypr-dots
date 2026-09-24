For NVIDIA setup:
nvidia-dkms
linux-headers
nvidia-utils
egl-wayland
libva-nvidia-driver

create and edit /etc/modprobe.d/nvidia.conf, and add this line to the file:
options nvidia_drm modeset=1

Electron or Chromium-based apps can stall for up to a minute after boot on hybrid graphics systems with an Intel iGPU and an NVIDIA dGPU.
This can be fixed by loading the i915 module before the NVIDIA ones in /etc/mkinitcpio.conf
/etc/mkinitcpio.conf
MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)

rebuild the initramfs with sudo mkinitcpio -P, and reboot

After rebooting, you can verify that DRM is actually enabled by running cat /sys/module/nvidia_drm/parameters/modeset, which should return Y.

Enable nvidia services:
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-resume.service
sudo systemctl enable nvidia-hibernate.service

Add nvidia.NVreg_PreserveVideoMemoryAllocations=1 to your kernel parameters
rebuild the initramfs with sudo mkinitcpio -P, and reboot

To fix instant wakeup on suspend:
Modify:
/etc/systemd/system-sleep/disable-xhci-wakeup 

```bash
#! /bin/bash
case $1 in
    pre)
        declare -a devices=(XHCI) # <-- Add your entries here

        for device in "${devices[@]}"; do
            if $(grep -qw ^${device}.*enabled /proc/acpi/wakeup); then
                echo ${device} > /proc/acpi/wakeup
            fi
        done
    ;;
esac
```

To sync system clock if disabled:
sudo systemctl enable --now systemd-timesyncd

For nvme:
sudo systemctl enable --now fstrim.timer

paccache.timer (optional)


Packages (pacman):
hyprland
pipewire-pulse
pavucontrol
awww
neovim
wl-clipboard
ripgrep
python-pipx
xdg-desktop-portal-hyprland
less
eza
fzf
imagemagick
wget
thunar
    tumbler
usbutils
nnn
etckeeper

yay:
vscodium
zen-browser
    pipewire-jack

