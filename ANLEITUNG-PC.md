# Installation auf meinem Rechner

> ⚠️ Nur **Boot, Swap und Root** werden formatiert. `/programmieren` und `/spiele` bleiben unangetastet.
> Die Partitionsnummern unten sind Beispiele. **Vorher mit `lsblk -f` prüfen!**

## 1. Arch-ISO booten

```bash
loadkeys de-latin1
iwctl station wlan0 connect "<WLAN-Name>"   # nur bei WLAN
pacman -Sy archinstall
lsblk -f                                     # Partitionen prüfen!
```

## 2. Boot, Swap und Root formatieren und mounten

```bash
BOOT=/dev/nvme0n1p1  SWAP=/dev/nvme0n1p2  ROOT=/dev/nvme0n1p3   # anpassen!

mkfs.fat -F 32 $BOOT
mkswap $SWAP && swapon $SWAP
mkfs.ext4 -F $ROOT
mount --mkdir $ROOT /mnt
mount --mkdir $BOOT /mnt/boot
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

Als dein User einloggen (TTY):

```bash
git clone https://github.com/SchnuBby2205/sArch-ansible.git ~/sArch-ansible
cd ~/sArch-ansible
nano host_vars/pc.yml          # nur beim ersten Mal: Partitionen/UUIDs prüfen
./sarch.sh pc                  # fragt einmal das sudo-Passwort ab
reboot
```

## 5. Fertig

SDDM startet Hyprland automatisch.

- **Wallpaper:** wie gewohnt mit `sarch_change_wallpaper.sh` setzen.
- **Steam:** einmal starten.
- **Optional:** Steht im Ansible-Log eine neue `Firefox Install-Kennung(en): …`, diese in
  `host_vars/pc.yml` bei `install_hash` eintragen und committen.
- **Optional:** Ansible wieder entfernen mit `./sarch.sh cleanup`.
