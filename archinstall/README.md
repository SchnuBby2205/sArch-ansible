Hier deine `settings.json` für archinstall ablegen (ohne Passwörter).

Muss enthalten bzw. im Menü so eingestellt sein:

- Disk: **Pre-mounted configuration** `/mnt`
- Kernel: `linux-lts`
- Bootloader: **GRUB**
- Network: **NetworkManager**
- Profil: **Minimal**, Audio: keins, zram/Swap: aus
- Zusatzpakete: `git base-devel efibootmgr`
- `Europe/Berlin`, `de_DE.UTF-8`, `de-latin1`
- Mirror-Region: Germany

Die JSON-Schlüssel ändern sich zwischen archinstall-Versionen. Am sichersten im Menü prüfen
und über **„Save configuration“** neu speichern.
