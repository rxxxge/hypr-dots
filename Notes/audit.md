# Arch Linux: Audit Guide for an Aged System

How to find out what's on your system, what each finding means, and whether to act.

**Golden rule: reversible steps first.**
Observe → disable (don't remove) → mask → remove the package. For files: move to a quarantine folder, wait 2–4 weeks, then delete. Change one thing at a time and note what you did.

---

## 0. Before you touch anything

- [ ] Backup or snapshot (btrfs snapshot, restic/borg, or at least a copy of `/etc` and `~`)
- [ ] Have a rescue path: Arch USB, or `linux-lts` installed
- [ ] Save baselines you can diff against later:
  ```bash
  mkdir -p ~/audit-baseline && cd ~/audit-baseline
  pacman -Qqe > explicit.txt
  pacman -Qqm > foreign.txt
  systemctl list-unit-files --state=enabled --no-legend > units-system.txt
  systemctl --user list-unit-files --state=enabled --no-legend > units-user.txt
  sudo ss -tulpn > ports.txt
  ```
- [ ] `sudo pacman -S etckeeper && sudo etckeeper init` (baseline commit of current `/etc`; from now on every change is tracked. It can't recover *past* history.)
  - `/etc` holds secrets (Wi-Fi PSKs, `shadow`). **Never push it to a public remote.**
- [ ] Quarantine helpers:
  ```bash
  mkdir -p ~/.quarantine        # for home files
  sudo mkdir -p /root/quarantine  # for system files; log every move:
  echo "$(date +%F) moved /path/to/file (reason)" | sudo tee -a /root/quarantine/LOG
  ```
- [ ] Install tools: `sudo pacman -S pacman-contrib expac ncdu fatrace` and (AUR) `lostfiles`, `xdg-ninja`

---

## 1. "Where did this come from?" toolkit

This is the answer to *"I can't know what came from which package."*

| Question | Command |
|---|---|
| Which package owns this file? | `pacman -Qo /path/to/file` |
| What files does this package install? | `pacman -Ql pkg` |
| What is this package, why is it here, who needs it? | `pacman -Qi pkg` → read **Install Reason**, **Required By**, **Optional For**, **Install Date** |
| Which package *would* provide a file I don't have? | `sudo pacman -Fy` once, then `pacman -F filename` |
| Why is package X installed? (dependency chain) | `pactree -r pkg` (reverse deps) |
| What did I install and when? | `expac --timefmt='%F %T' '%l\t%n' \| sort \| tail -50` |
| Full history for one package | `grep 'pkgname' /var/log/pacman.log` |
| Which package shipped this systemd unit? | `systemctl cat foo.service` (top line shows path) → `pacman -Qo <that path>` |
| What did *I* change in `/etc` from package defaults? | `sudo pacman -Qii \| awk '/^MODIFIED/ {print $2}'` |
| Exactly how does my file differ from the shipped one? | `bsdtar -xOf /var/cache/pacman/pkg/PKG.pkg.tar.zst etc/foo.conf \| diff - /etc/foo.conf` |
| Which systemd units are overridden or extended by me? | `systemd-delta` |
| Which process owns this listening port/PID? | `sudo ss -tulpn` then `systemctl status <PID>` and `pacman -Qo $(readlink /proc/<PID>/exe)` |

**If `pacman -Qo` says "No package owns…"**, the file came from one of these: you, a `make install`/`pip`/`npm -g`, a third-party installer, a program generating it at runtime, or a package that has since been removed. Each case is handled below.

---

## 2. Everything that can start something on your system

"Enabled services" is only *one* way things run. To have full control, check all of them:

| Mechanism | How to list it |
|---|---|
| Enabled system units | `systemctl list-unit-files --state=enabled` |
| Enabled user units | `systemctl --user list-unit-files --state=enabled` |
| Socket activation (starts on first connection, without being "enabled") | `systemctl list-sockets --all` |
| Timers | `systemctl list-timers --all` and `systemctl --user list-timers --all` |
| Path units | `systemctl list-units --type=path --all` |
| D-Bus activation (started when some app asks for it) | `ls /usr/share/dbus-1/system-services /usr/share/dbus-1/services`, `busctl list --activatable` |
| udev rules that start units | `grep -rl SYSTEMD_WANTS /usr/lib/udev/rules.d /etc/udev/rules.d` |
| Desktop autostart | `ls ~/.config/autostart /etc/xdg/autostart` |
| WM/session scripts | `~/.xinitrc`, `~/.xprofile`, WM config `exec`/`exec-once` lines, `~/.profile`, shell rc files |
| Cron / at | `crontab -l`, `sudo ls /etc/cron.*`, `atq` (usually nothing on Arch) |
| Kernel modules loaded at boot | `ls /etc/modules-load.d`, `lsmod` |
| Kernel command line | `cat /proc/cmdline` |

**Why did this start?** `systemctl list-dependencies --reverse foo.service` shows what pulls it in.
**What is running, grouped by unit?** `systemd-cgls` (tree) and `systemd-cgtop` (resource use).

---

## 3. Reading your audit results

### 3.1 `systemctl --failed`
- A failed unit is a config problem, a missing device, or a leftover from something you changed.
- Investigate: `systemctl status x` then `journalctl -u x -b`.
- **Action:** fix it, or if you don't need it, `disable --now` (and remove the package). Don't just `reset-failed` and forget it.

### 3.2 `systemctl list-unit-files` states
| State | Meaning | Care? |
|---|---|---|
| enabled | starts at boot | **Yes, these are what you audit** |
| disabled | exists, won't auto-start (may still be started by something else) | no |
| static | can't be enabled; only pulled in by other units | usually no |
| indirect / alias / generated | plumbing | no |
| masked | hard-blocked | that's your own work (or a deliberate one) |

### 3.3 Common services: what they are and whether you need them
| Unit | Purpose | Verdict |
|---|---|---|
| systemd-journald, systemd-udevd, systemd-logind, dbus / dbus-broker | core system | **Keep** |
| getty@tty1 | login console | Keep |
| systemd-timesyncd / chronyd / ntpd | time sync | Keep **exactly one** |
| NetworkManager / systemd-networkd / iwd / dhcpcd | networking | **One stack only**; two managers fighting causes weird bugs. wpa_supplicant/iwd is a backend for it. |
| systemd-resolved | DNS stub resolver | Fine if it's your only DNS manager. Check `ls -l /etc/resolv.conf` to see who owns DNS. |
| NetworkManager-wait-online / systemd-networkd-wait-online | delays boot until network is up | Usually safe to disable unless a boot-time mount/service needs network |
| polkit | privilege prompts | Keep (starts on demand) |
| udisks2 | GUI automounting | Optional; disable if you mount by hand |
| upower | battery/power info | Keep on laptops/DEs |
| pipewire, wireplumber, pipewire-pulse (user), rtkit-daemon | audio | Keep if you use audio |
| bluetooth | Bluetooth | Only if you have/use it |
| cups, cups-browsed | printing (`cups-browsed` also listens on the network) | Only if you print |
| avahi-daemon | mDNS/zeroconf discovery | Usually unnecessary |
| ModemManager | mobile modems | Unnecessary unless you use a modem |
| sshd | remote login | Only if you SSH *into* this machine |
| accounts-daemon, colord, geoclue | desktop helpers | DE-dependent; check `pacman -Qi` "Required By" before removing |
| power-profiles-daemon / tlp / thermald | power management | Keep one (not multiple) if wanted |
| lvm2-monitor, mdmonitor | LVM / RAID | Only if you use LVM / mdraid |
| docker, containerd, libvirtd | containers/VMs | Only if used; also big data in `/var/lib` |
| reflector.timer | mirrorlist refresh | Fine |
| fstrim.timer | weekly SSD trim | **Keep on SSD** |
| systemd-oomd, systemd-homed | optional | Rarely needed |

**How to disable safely:**
```bash
sudo systemctl disable --now foo.service foo.socket   # include the .socket or it comes back
# later, if you never need it:
sudo systemctl mask foo.service
# even later, if it's clearly unused:
sudo pacman -Rnsp foo    # -p = dry run: READ the list it prints
sudo pacman -Rns  foo
```

### 3.4 Timers and scheduled jobs
Expected on a healthy Arch: `fstrim`, `man-db`, `shadow`, `systemd-tmpfiles-clean`, `archlinux-keyring-wkd-sync`, `paccache` / `reflector` / `logrotate` / `updatedb` if you installed them.
Anything else: `systemctl cat name.timer` and `pacman -Qo` its path. If unowned, it's something you or a script created. Also check user timers, `crontab -l`, and `/etc/cron.*`.

### 3.5 Listening ports: `sudo ss -tulpn`
Read the **Local Address** column:
- `127.0.0.1` / `[::1]` / `127.0.0.53` = only your own machine can reach it. Low concern.
- `0.0.0.0` / `[::]` / `*` = reachable from your network. **Every one of these needs an explanation.**

| Port | Usually is |
|---|---|
| 22/tcp | sshd |
| 53 (127.0.0.53) | systemd-resolved stub |
| 68/udp | DHCP client (NetworkManager/dhcpcd/networkd) |
| 323/udp (localhost) | chronyd |
| 631 | CUPS / cups-browsed |
| 5353/udp | mDNS (avahi or resolved) |
| high random port | some desktop app, KDE Connect (1714–1764), Syncthing (22000), a dev server, etc. |

**Action:** identify the process (table in §1), then stop the service, or bind it to localhost, or firewall it. Check the firewall with `sudo nft list ruleset`, or `sudo ufw status` if you use ufw.

### 3.6 Boot: `systemd-analyze`
- `blame` shows what took long, **not what blocked boot**. Use `systemd-analyze critical-chain` for the real chain.
- Slow `dev-*.device` or long mount waits = **stale `/etc/fstab` entries** for disks you no longer have. Run `findmnt --verify`. Add `nofail` or delete dead lines.
- `NetworkManager-wait-online` is very often the top item and often unnecessary (see 3.3).
- `systemd-udev-settle` is deprecated; something is pulling it in (`systemctl list-dependencies --reverse systemd-udev-settle.service`).
- Read warnings too: `journalctl -b -p warning` and `sudo dmesg --level=err,warn`.
- Stale boot entries are common on old systems: `bootctl status`, `bootctl list`, `efibootmgr -v` (old distros, dead disks). Delete with `sudo efibootmgr -b XXXX -B` only when sure.
- Kernels: `ls /boot`, `ls /usr/lib/modules`. Keep only the kernels you use.

### 3.7 Package lists
| Command | Meaning | Action |
|---|---|---|
| `pacman -Qdtq` | **Orphans**: deps nothing needs | Review, then `pacman -Qdtq \| sudo pacman -Rns -` |
| `pacman -Qdttq` | Deps needed only *optionally* by others | Optional deps are the "nice to have" features, so review each; often safe to remove |
| `pacman -Qqett` | Explicit packages nothing depends on: your **real intent list** | Go through every line: "do I know why this is here?" If not, `pacman -Qi` it and decide |
| `comm -23 <(pacman -Qqe\|sort) <(pacman -Qqett\|sort)` | Explicit packages that other packages need anyway | Mark as deps so they clean up automatically later: `sudo pacman -D --asdeps pkg` |
| `pacman -Qm` | **Foreign**: AUR, manual builds, or packages dropped from the repos | Per package: still want it? still maintained? now in official repos (`pacman -Si pkg`)? Reinstall from repo if so. `-debug` packages and `*-git` packages you forgot about are common junk. |
| `pacman -Qn` | Official-repo packages only | (for comparison) |

Marking "as explicit vs as dependency" only changes bookkeeping, not what's installed.

### 3.8 Integrity: `sudo pacman -Qkk`
Show only the warnings, hide `/etc` customizations:
```bash
sudo pacman -Qkk 2>&1 >/dev/null | grep -v 'backup file'
```
| Message | Meaning | Concern |
|---|---|---|
| `backup file: … (Size/checksum mismatch)` | Config you edited | Expected. It's your customization. |
| `Modification time mismatch` (alone) | Timestamp changed, contents same | Usually harmless (caches, generated files) |
| `Permissions mismatch` | chmod/chown'd by you or a script | Check whether it's intentional |
| `No such file` | Deleted (by you, a cleanup, or tmpfiles) | Reinstall the package if it matters: `sudo pacman -S pkg` |
| `Size / checksum mismatch` on files in `/usr`, `/bin` | Binary or library replaced or modified | **Investigate.** Could be a manual overwrite, a corrupted disk, or something worse. Reinstall: `sudo pacman -S pkg`. If it recurs, check disk health (`smartctl -a`). |

### 3.9 Unowned files: `sudo pacreport --unowned-files`, `sudo lostfiles`
Judge by location:

| Location | Meaning | Action |
|---|---|---|
| `/etc` (`hostname`, `fstab`, `machine-id`, `passwd`, `shadow`, `group`, `locale.conf`, `vconsole.conf`, `localtime`, `ssh/ssh_host_*`, `pacman.d/gnupg/*`, `ssl/certs/*` and `ca-certificates/*`, `resolv.conf`) | **Normal**; system-generated or set by you | Leave alone |
| `/etc` (anything else) | Config you or an installer wrote, or leftover from a removed package | Read it. If nothing uses it, quarantine it. |
| `/usr/local`, `/opt` | Not pacman-managed. Manual installs. | Identify each (`ls`, check the program), then remove it or package it |
| `/usr/lib/python3.*` (old version numbers) | Left over after a Python upgrade, or from `sudo pip` | Compare to `python --version`. Old-version dirs with unowned content are dead; quarantine. |
| `/usr/lib/modules/<kernel>` not matching an installed kernel | Stale module dir from a removed/updated kernel | If not `uname -r` and not installed: `sudo rm -r` (or quarantine). *Reboot after kernel updates.* |
| `/usr/bin`, `/usr/lib` (random files) | Manual install or an old package's runtime-generated leftovers | Identify, then quarantine |
| `/var/lib/<name>` | Data from a removed package (docker, libvirt, mysql, etc.) | Pacman deliberately keeps this. If you're sure you don't need the data, remove it. |
| `/var/cache`, `/var/tmp`, `/tmp` | Caches / temp | See §3.10 |

**Owned by nobody:** `sudo find / -xdev \( -nouser -o -nogroup \) 2>/dev/null` finds files owned by users/groups that no longer exist (removed packages, old containers). Investigate; usually deletable.
**Broken symlinks:** `sudo find /usr /etc /var /opt -xtype l 2>/dev/null` finds dead links. In `/etc/systemd`, they're units of removed packages: `sudo find /etc/systemd -xtype l -delete` after you eyeball the list.
**Suspicious SUID files:**
```bash
sudo find / -xdev -type f -perm -4000 -exec pacman -Qo {} \; 2>&1 | grep -i 'no package owns'
```
Any SUID file not owned by a package deserves a serious look.

### 3.10 `/etc` leftovers
- `sudo pacdiff` or `sudo find /etc -name '*.pacnew' -o -name '*.pacsave'`. **`.pacnew`** = the package wants a new default config and you've modified the old one; merge or discard. **`.pacsave`** = config kept after its package was removed; delete if you don't need it.
- Files in `/etc/systemd/system`, `/etc/modprobe.d`, `/etc/sysctl.d`, `/etc/udev/rules.d`, `/etc/tmpfiles.d`, `/etc/modules-load.d`, `/etc/sudoers.d`, `/etc/polkit-1/rules.d`: any file here not owned by a package is your (forgotten) customization. Read each one; it's often a stale workaround for an old bug.

### 3.11 Disk usage: `sudo du -xh --max-depth=1 / | sort -h`, `sudo ncdu -x /`
| Where | Usually | Action |
|---|---|---|
| `/var/cache/pacman/pkg` | package cache | `sudo paccache -rk2`; `sudo paccache -ruk0` (uninstalled pkgs) |
| `/var/log/journal` | journal | `journalctl --disk-usage`; cap with `SystemMaxUse=` (see README) |
| `/var/lib/systemd/coredump` | crash dumps | `coredumpctl list`; delete; set `Storage=none` |
| `/var/lib/docker`, `/var/lib/containers`, `/var/lib/libvirt` | containers/VMs | `docker system df`; `docker system prune` (understand it first) |
| `/var/lib/flatpak` | Flatpak | `flatpak uninstall --unused` |
| `/var/tmp` | survives reboot | delete old files |
| `/swapfile` | swap | normal; verify with `swapon --show` |

### 3.12 Home directory
1. **Sort by age:** `ls -lAtr ~ | head -40` shows the oldest-touched entries first. Same for `~/.config`, `~/.local/share`. Untouched for years + app not installed = dead.
2. **Is the app still installed?** `command -v appname` and `pacman -Qs appname`. If not, its `~/.config/appname`, `~/.local/share/appname` and `~/.cache/appname` are orphans. Quarantine them.
3. **Common junk after an old install:**
   - `~/.local/lib/python3.X/` for an old Python version: dead after a Python upgrade. Compare with `python --version`. Reinstall tools with `pipx` afterwards.
   - `~/.cache`: always safe to delete (`ncdu ~/.cache`)
   - `~/.npm`, `~/.cargo`, `~/.rustup`, `~/go`, `~/.gradle`, `~/.m2`, `~/.nvm`, `~/.pyenv`: dev toolchains and caches. Keep only what you use.
   - `~/.var/app` (Flatpak data), `~/.local/share/Trash`, `~/.local/share/applications/*.desktop` (stale launchers)
   - `~/.local/bin`: read every script; delete what you don't recognize
4. **Broken links:** `find ~ -xdev -xtype l` finds dead symlinks.
5. **Who keeps writing here?** `sudo fatrace -f W -t 2>/dev/null | grep "$HOME"` (Ctrl-C to stop) shows the process writing each file. Use `xdg-ninja` to see how to redirect it to XDG paths.
6. **Standard structure:** decide your layout once, and check `ls -A ~` regularly.

---

## 4. Should I do anything? Decision rubric

| Situation | Do |
|---|---|
| I can explain it and use it | Leave it. Write nothing down. |
| I can explain it but don't use it | Disable → wait → remove package |
| I can't explain it, `pacman -Qi` shows it's a dependency of something I use | Leave it. That's what dependencies are. |
| I can't explain it, no package owns it | Identify. Quarantine, wait 2–4 weeks, delete if nothing broke. |
| I can't explain it, it's on the network (`0.0.0.0` port, unowned SUID, unowned unit) | **Stop and investigate first.** This is the one category worth urgency. |
| Removal list from `pacman -Rns` includes things I care about | Stop. Don't remove. |

**Never remove without reading:** `base`, `linux*`, `linux-firmware`, `systemd`, `pacman`, your bootloader, `glibc`, `bash`/your shell, `sudo`, `networkmanager` (if it's your only network stack). Always use the `-p` dry run first.

After any boot-affecting change (units, fstab, mkinitcpio, kernel params): reboot and check `systemctl --failed` and `journalctl -b -p err`.

---

## 5. Checklists

### One-time cleanup of the old system
- [ ] §0 done (backup, baseline, etckeeper, quarantine)
- [ ] `systemctl --failed` is empty
- [ ] Every enabled system and user unit is explained
- [ ] Only one network stack, one time-sync service
- [ ] `ss -tulpn`: every `0.0.0.0` / `[::]` listener explained
- [ ] `/etc/fstab` verified (`findmnt --verify`)
- [ ] `.pacnew` / `.pacsave` files handled (`pacdiff`)
- [ ] `pacman -Qqett` reviewed line by line; explicit-but-required packages marked `--asdeps`
- [ ] Orphans (`-Qdtq`, `-Qdttq`) reviewed and removed
- [ ] Foreign packages (`-Qm`) reviewed
- [ ] `pacman -Qkk` warnings reviewed; nothing odd under `/usr`
- [ ] `/usr/local` and `/opt` explained or removed
- [ ] Unowned files, unowned-user files, broken symlinks, unowned SUIDs reviewed
- [ ] Old kernels / module dirs / boot entries removed
- [ ] `/var` capped (journal, coredumps, pacman cache)
- [ ] Home: dead dotfiles quarantined, `~/.cache` cleared, `xdg-ninja` run
- [ ] Reboot; `systemd-analyze critical-chain` looks sane

### Monthly (or after installing anything)
- [ ] `systemctl --failed`
- [ ] Compare enabled units against baseline: `diff units-system.txt <(systemctl list-unit-files --state=enabled --no-legend)` (same for user units)
- [ ] Compare listening ports: `sudo ss -tulpn`
- [ ] `pacman -Qdtq`, `pacman -Qm`, and `diff explicit.txt <(pacman -Qqe)` for anything new
- [ ] `pacdiff -o`
- [ ] `find /usr/local /opt -maxdepth 2`
- [ ] `sudo paccache -rk2`, `journalctl --disk-usage`
- [ ] `ls -A ~`
- [ ] `git -C /etc log --stat -5` (etckeeper) to see recent config changes
- [ ] Read archlinux.org/news before big upgrades; never `-Sy` alone; reboot after kernel updates
- [ ] Refresh baselines when everything looks right

### Habits that prevent the mess
- Never `sudo make install`, `sudo pip install`, `sudo npm -g`. Use PKGBUILDs, `pipx`, venvs, containers.
- After installing any package: `pacman -Qi` its deps/optdeps, check for new enabled units or ports.
- Test new tools in `distrobox`/`podman` first.
- Write a one-line note to yourself whenever you edit a config.
