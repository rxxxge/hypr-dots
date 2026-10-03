# Arch Linux Reading List

## Arch Wiki pages

| Page | What it covers |
|------|----------------|
| General recommendations and System maintenance | The whole "how to look after an install" mindset |
| Pacman and Pacman/Tips and tricks | Orphans, foreign packages, ownership queries, cache cleanup |
| Pacman/Rosetta | Translates habits from apt, dnf and others |
| systemd, systemd/User, systemd/Timers | Units, sockets, timers and user services |
| Improving performance/Boot process | `systemd-analyze`, what actually slows boot |
| XDG Base Directory | The table of which programs put files where, and how to redirect them |
| File permissions and attributes | SUID/SGID and the modes we checked |
| Users and groups | Why `/etc/passwd` and friends differ from the package defaults |
| Mkinitcpio, GRUB, Kernel parameters | Your boot chain, file by file |
| PKGBUILD and Creating packages | For the local package idea for your customizations |
| Security | Hardening and the things worth being wary of |

## Man pages

They're the reference you'll use most once you're comfortable. Check `pacman -Q man-db man-pages` first, because I didn't see them in your list. Install both if they're missing.

```bash
pacman -Q man-db man-pages
```

- `pacman(8)`, `pacman.conf(5)`
- `systemd.unit(5)`, `systemd.service(5)`, `systemd.timer(5)`, `systemd.socket(5)`
- `systemctl(1)`, `journalctl(1)`, `systemd-analyze(1)`
- `tmpfiles.d(5)` and `sysusers.d(5)`, which explain the "package creates files or users" behavior we ran into (`/var/log/journal`, for example)
- `hier(7)`, which explains what every top-level directory is for

## Books and guides

- **The Linux Command Line** by William Shotts is free at [linuxcommand.org](https://linuxcommand.org).
- **How Linux Works** by Brian Ward covers boot, devices, networking and the whole userland, and it's excellent for the "what is my system actually doing" question.
- **"systemd for Administrators"** is Lennart Poettering's blog series (search for it on 0pointer.de). It's short and reads well.
- **Julia Evans' zines** at [wizardzines.com](https://wizardzines.com) are cheap and very good on `strace`, permissions and how Linux fits together.

## Specifications behind the rules

- **The XDG Base Directory Specification** (freedesktop.org) is what `xdg-ninja` enforces.
- **The Filesystem Hierarchy Standard** explains why `/usr/local`, `/opt` and `/var` exist, so you know where a stray file should have gone.
