# Installation in einer VM

Unterschiede zum PC: Die Platte ist `/dev/vda` (leer), es gibt keine `/programmieren`- oder
`/spiele`-Platte, kein Backup und kein Firefox-Profil. Das steckt alles in `host_vars/vm.yml`.

**VM-Einstellungen:**

- **Firmware:** **UEFI** (GRUB wird als EFI installiert).
  - virt-manager: *Firmware: UEFI*
  - VirtualBox: *EFI aktivieren*
- **Platte:** mindestens 30 GB, RAM mindestens 4 GB.
- **Grafik:** Hyprland braucht 3D-Beschleunigung.
  - virt-manager: *Video: Virtio + 3D acceleration*, *Display Spice: OpenGL*

## 1. Arch-ISO booten

```bash
loadkeys de-latin1
pacman -Sy archinstall
```

## 2. Platte partitionieren, formatieren, mounten

Die ganze Platte `/dev/vda` wird gelöscht.

```bash
sfdisk /dev/vda <<'P'
label: gpt
,1G,U
,4G,S
,,L
P

mkfs.fat -F 32 /dev/vda1
mkswap /dev/vda2 && swapon /dev/vda2
mkfs.ext4 -F /dev/vda3
mount --mkdir /dev/vda3 /mnt
mount --mkdir /dev/vda1 /mnt/boot
```

## 3. archinstall

```bash
curl -LO https://raw.githubusercontent.com/SchnuBby2205/sArch-ansible/main/archinstall/settings.json
archinstall --config settings.json
```

Im Menü prüfen:

- **Disk configuration:** *Pre-mounted configuration* → `/mnt`
- **Root-Passwort** setzen, **User mit sudo** anlegen
- dann **Install**. Die Frage nach chroot mit *Nein* beantworten.

```bash
umount -R /mnt && reboot
```

## 4. Ansible-Lauf

Als dein User einloggen:

```bash
git clone https://github.com/SchnuBby2205/sArch-ansible.git ~/sArch-ansible
cd ~/sArch-ansible
./sarch.sh vm
reboot
```

## 5. Fertig

- **Wallpaper:** mit `sarch_change_wallpaper.sh` setzen.
- **Optional:** Ansible wieder entfernen mit `./sarch.sh cleanup`.
