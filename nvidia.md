For NVIDIA setup (packages to install):
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
```
options nvidia NVreg_PreserveVideoMemoryAllocations=1
```

To fix instant wakeup on suspend:
Modify:
/etc/tmpfiles.d/disable-usb-wake.conf 

```bash
#    Path                  Mode UID  GID  Age Argument
w!   /proc/acpi/wakeup     -    -    -    -   XHCI
```

To fix lag or stutter in hyprland it's possible to boost minimum graphics clock speeds:
`sudo nvidia-smi -lgc MIN_CLOCK(e.g 705),MAX_CLOCK(2100)`

check with `nvidia-smi -q -d SUPPORTED_CLOCKS`

Make it permanent:
Modify `/etc/systemd/system/nvidia-clocks.service`:
```
[Unit]
Description=Set NVIDIA GPU minimum clocks to avoid GSP timeouts/general system lag for composidors
Requires=nvidia-persistenced.service
After=nvidia-persistenced.service 

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -lgc MIN_CLOCK,MAX_CLOCK (705,2100)
RemainAfterExit=yes 

[Install]
WantedBy=multi-user.target
```

To sync system clock if disabled:
sudo systemctl enable --now systemd-timesyncd

For nvme:
sudo systemctl enable --now fstrim.timer

paccache.timer (optional)

Security:
set UMASK to 027 in /etc/login.defs


**obsolete**
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

