#!/usr/bin/env bash
# sArch-Ansible – Steuerskript
#   ./sarch.sh pc            System einrichten / abgleichen (mein Rechner)
#   ./sarch.sh vm            dasselbe für die Test-VM
#   ./sarch.sh pc update     git pull + Systemupdate (pacman + AUR) + abgleichen
#   ./sarch.sh cleanup       Ansible wieder entfernen
# Weitere ansible-playbook-Optionen einfach anhängen, z. B. ./sarch.sh pc --check --diff
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

[[ $EUID -eq 0 ]] && { echo "Bitte als normaler User starten, nicht als root."; exit 1; }

usage() { sed -n '3,7p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

install_ansible() {
  if ! command -v ansible-playbook >/dev/null; then
    echo ">> Installiere Ansible ..."
    sudo pacman -Syu --needed --noconfirm ansible git base-devel
  fi
  ansible-galaxy collection install -r requirements.yml >/dev/null
}

cleanup() {
  echo ">> Entferne Ansible und seine Abhängigkeiten ..."
  sudo pacman -Rns --noconfirm ansible || true
  rm -rf "$HOME/.ansible"
  if [[ "${1:-}" == "--all" ]]; then
    echo ">> Entferne Build-User aur_builder ..."
    sudo rm -f /etc/sudoers.d/11-install-aur_builder
    sudo userdel -r aur_builder 2>/dev/null || true
  fi
  echo ">> Fertig. Das sArch-System selbst bleibt unverändert."
}

case "${1:-}" in
  pc|vm)
    host=$1; shift
    extra=()
    if [[ "${1:-}" == "update" ]]; then
      shift
      echo ">> git pull (sArch-ansible und sArch) ..."
      git pull --ff-only || echo "!! sArch-ansible: git pull nicht möglich, mache mit lokalem Stand weiter."
      [[ -d "$HOME/sArch/.git" ]] && { git -C "$HOME/sArch" pull --ff-only \
        || echo "!! sArch: git pull nicht möglich (lokale Änderungen?), mache mit lokalem Stand weiter."; }
      extra+=(-e sarch_upgrade=true)
    fi
    install_ansible
    ansible-playbook site.yml --limit "$host" --ask-become-pass "${extra[@]}" "$@"
    ;;
  cleanup) shift; cleanup "${1:-}" ;;
  *) usage ;;
esac
