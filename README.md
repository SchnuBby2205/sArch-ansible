# sArch-ansible

Richtet ein frisches Arch Linux (aus archinstall) als sArch-Desktop ein: Hyprland, Programme,
AUR-Pakete, GPU-Treiber, Dotfiles aus [sArch](https://github.com/SchnuBby2205/sArch),
Mounts, Autologin und Firefox-Profil.

| Anleitung | |
|---|---|
| [ANLEITUNG-PC.md](ANLEITUNG-PC.md) | Installation auf meinem Rechner |
| [ANLEITUNG-VM.md](ANLEITUNG-VM.md) | Installation in einer Test-VM |

## Befehle

```bash
./sarch.sh pc              # einrichten / abgleichen (vm statt pc für die VM)
./sarch.sh pc update       # Systemupdate (pacman + AUR) + Repos aktualisieren + abgleichen
./sarch.sh pc --check --diff   # Probelauf: zeigt nur, was passieren würde
./sarch.sh pc --tags dotfiles  # nur einen Teil (system, packages, aur, gpu, dotfiles, personal)
./sarch.sh cleanup         # Ansible wieder entfernen
./sarch.sh cleanup --all   # zusätzlich den Build-User aur_builder entfernen
```

`sarch.sh` installiert Ansible automatisch, wenn es fehlt.

## Wo stellt man was ein?

| Datei | Inhalt |
|---|---|
| `group_vars/all.yml` | gilt für alle: Paketlisten, AUR-Pakete, Dienste, Dotfile-Modus |
| `host_vars/pc.yml` | mein Rechner: GPU, Swap, `/programmieren`, `/spiele`, Backup-Links, Firefox |
| `host_vars/vm.yml` | VM: `/dev/vda2` als Swap, keine Mounts, kein Firefox-Profil |

**Programm hinzufügen:** in `sarch_programs` bzw. `sarch_aur_packages` eintragen, dann `./sarch.sh pc`.

**Neue Config:** Ordner im sArch-Repo unter `configs/` anlegen. Er wird automatisch nach
`~/.config/` verlinkt.

## Update

```bash
cd ~/sArch-ansible && ./sarch.sh pc update
```

Das macht drei Dinge:

1. `git pull` für sArch-ansible und `~/sArch`
2. Systemupdate: `pacman -Syu` und AUR-Pakete über `yay`
3. Abgleich wie bei `./sarch.sh pc`: neue Pakete installieren, neue Configs verlinken usw.

Wurde Ansible vorher mit `cleanup` entfernt, installiert `sarch.sh` es dafür wieder.
Danach kannst du es erneut entfernen.

## Ansible wieder entfernen

`./sarch.sh cleanup` entfernt das Paket `ansible` samt nicht mehr benötigter Abhängigkeiten
(`pacman -Rns`) und `~/.ansible` (die Collections). Das eingerichtete System bleibt unverändert.

Was danach noch übrig bleibt:

| Was | Warum |
|---|---|
| `yay` | dein AUR-Helfer, wird normal weiterbenutzt |
| `python` | wird von anderen Paketen gebraucht (pywalfox, settings_mask.py …) |
| User `aur_builder` + `/etc/sudoers.d/11-install-aur_builder` | baut AUR-Pakete bei Ansible-Läufen. Mit `cleanup --all` weg |
| `~/sArch-ansible`, `~/sArch` | die Repos. `~/sArch` muss bleiben, weil die Configs dorthin verlinkt sind |

## Hinweise

- **Configs sind Symlinks** nach `~/sArch/configs/…`. Änderungen landen direkt im sArch-Repo.
  Dazu gehören auch die Farbdateien, die matugen beim Wallpaper-Wechsel schreibt.
  `sarch_dotfiles_mode: copy` kopiert stattdessen.
- **Firefox-Profil (nur PC):** Das Profil vom Backup-Laufwerk wird verlinkt und als Standard
  eingetragen. Die Install-Kennung ermittelt Ansible selbst. Notfalls startet es Firefox dafür
  einmal kurz unsichtbar. Die Kennung wird im Lauf angezeigt. Trägst du sie in
  `host_vars/pc.yml` → `install_hash` ein, ist sie bei jeder Neuinstallation sofort da.
  Firefox muss während des Laufs geschlossen sein.
- **AUR:** Ein eigener User `aur_builder` darf nur `pacman` ohne Passwort ausführen.
  Das ist das empfohlene Muster der Collection `kewlfft.aur`.
- **Kein matugen im Playbook:** Das Wallpaper setzt du mit `sarch_change_wallpaper.sh`.
  Bis dahin gelten die Farbdateien aus dem Repo.
