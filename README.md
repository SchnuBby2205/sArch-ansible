# sArch-ansible

Richtet ein frisches Arch Linux (aus archinstall) als sArch-Desktop ein: Hyprland, Programme,
AUR-Pakete, GPU-Treiber, Dotfiles, Mounts, Autologin und Firefox-Profil.
Configs, Skripte, Themes und Fonts liegen direkt in diesem Repo.

## Aufbau

```
sArch-ansible/
├── configs/            Dotfiles → werden nach ~/.config/<ordner> verlinkt (hypr, kitty, rofi, …)
├── bin/                Helfer-Skripte → ~/.config/sArch/bin
├── themes/Matugen/     GTK-Theme → ~/.themes/Matugen
├── fonts/              eigene Fonts → ~/.local/share/fonts/sArch
├── group_vars/all.yml  Einstellungen für alle Rechner (Pakete, AUR, Dienste …)
├── host_vars/          pc.yml, vm.yml – rechnerspezifisch (GPU, Platten, Mounts, Firefox)
├── roles/              die Ansible-Rollen
├── archinstall/        settings.json für archinstall
├── site.yml            das Playbook
└── sarch.sh            Steuerskript (einrichten, update, cleanup)
```

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

**Neue Config:** Ordner unter `configs/` anlegen. Er wird automatisch nach
`~/.config/` verlinkt.

## Update

```bash
cd ~/sArch-ansible && ./sarch.sh pc update
```

Das macht drei Dinge:

1. `git pull` für dieses Repo (Playbook und Configs)
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
| `~/sArch-ansible` | das Repo. Muss bleiben, weil die Configs dorthin verlinkt sind |

## Hinweise

- **Configs: `link` oder `copy`** (`sarch_dotfiles_mode` in `group_vars/all.yml`, oder pro Rechner in `host_vars/*.yml`):
  - `link` (Standard): Symlinks nach `~/sArch-ansible/configs/…`. Änderungen landen direkt im Repo,
    auch die Farbdateien von matugen. `git pull` wirkt sofort.
  - `copy`: echte Kopien in `~/.config`. Das Repo bleibt sauber, und eigene Änderungen werden nie
    überschrieben. Es werden nur fehlende Dateien kopiert. Geänderte Dateien aus dem Repo
    musst du bei Bedarf selbst übernehmen, z. B. mit
    `cp ~/sArch-ansible/configs/kitty/kitty.conf ~/.config/kitty/`.
  - Beim Umstieg von `link` auf `copy` ersetzt der nächste Lauf die Symlinks durch Kopien.
- **matugen-Farbdateien ausblenden** (nur `link`, Standard an: `sarch_ignore_matugen_changes`):
  Ansible liest die `output_path`-Einträge aus `configs/matugen/config.toml` und markiert die
  passenden Dateien im Repo mit `git update-index --skip-worktree`. matugen schreibt sie
  weiter, aber `git status` zeigt nur noch deine echten Änderungen. Neue Ausgabedateien in der
  config.toml werden beim nächsten Lauf automatisch mit erfasst.
  - Neue Standardfarben bewusst committen:
    `git -C ~/sArch-ansible update-index --no-skip-worktree configs/kitty/colors.conf`,
    dann normal `git add` und `commit`.
  - Ändert sich eine dieser Dateien im Remote-Repo, bricht `git pull` ab. `sarch.sh update`
    meldet das und macht mit dem lokalen Stand weiter. Lösung: Datei wie oben wieder
    einblenden, `git checkout -- <datei>`, dann `git pull`.
- **Firefox-Profil (nur PC):** Das Profil vom Backup-Laufwerk wird verlinkt und als Standard
  eingetragen. Die Install-Kennung ermittelt Ansible selbst. Notfalls startet es Firefox dafür
  einmal kurz unsichtbar. Die Kennung wird im Lauf angezeigt. Trägst du sie in
  `host_vars/pc.yml` → `install_hash` ein, ist sie bei jeder Neuinstallation sofort da.
  Firefox muss während des Laufs geschlossen sein.
- **AUR:** Ein eigener User `aur_builder` darf nur `pacman` ohne Passwort ausführen.
  Das ist das empfohlene Muster der Collection `kewlfft.aur`.
- **Kein matugen im Playbook:** Das Wallpaper setzt du mit `sarch_change_wallpaper.sh`.
  Bis dahin gelten die Farbdateien aus dem Repo.
