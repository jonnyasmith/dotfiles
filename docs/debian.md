# Debian Desktop

Debian is an apt machine, so `mise bootstrap` treats it exactly like Ubuntu:
the same `[bootstrap.packages]` `apt:` list, the same `pre-packages` repo hook
(1Password, Docker, VS Code, Chrome — Docker publishes a `trixie` suite), the
same `setup:debian` / `setup:gnome` tasks. Only the four deltas below differ.
Everything else a human must do is in [ubuntu.md](ubuntu.md).

## 1. Give your user sudo

The Debian installer only adds the first user to `sudo` when you leave the
**root password blank**. Set one and `jonny` has no sudo, which stops
`bootstrap.sh` at the first package install. Check with `groups`; repair with:

```shell
su -c '/usr/sbin/usermod -aG sudo jonny'
```

Log out and back in — group membership is read at login.

## 2. Enable contrib and non-free

Debian 13 ships `main non-free-firmware` only. The Microsoft fonts (contrib)
and `unrar` (non-free) are not reachable until you add the rest:

```shell
sudo sed -i 's/^Components: .*/Components: main contrib non-free non-free-firmware/' \
  /etc/apt/sources.list.d/debian.sources
sudo apt update && sudo apt upgrade -y && sudo apt install -y git
```

Reboot if that pulled a new kernel.

## 3. Bootstrap

SSH key, GitHub, clone, `./bootstrap.sh` — [ubuntu.md](ubuntu.md) section 3,
unchanged.

## 4. Two Ubuntu-only packages you do not get

`setup:debian` installs `ghostty` and `ubuntu-restricted-extras` behind an
`*ubuntu*` guard, because the first's PPA is built for Ubuntu suites only and
the second is an Ubuntu package. On Debian the task skips both. GNOME Console
(`kgx`) is the terminal until you build ghostty yourself; for the codecs and
fonts the Ubuntu metapackage would have pulled in:

```shell
sudo apt install -y libavcodec-extra ttf-mscorefonts-installer unrar
```
