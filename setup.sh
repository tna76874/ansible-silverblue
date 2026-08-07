#!/usr/bin/env bash
set -e

# Konfiguration
REPO_URL="https://github.com/tna76874/ansible-silverblue.git"
TARGET_DIR="$HOME/.local/share/silverblue-setup"

echo "=== Fedora Silverblue Ansible Installer ==="

# 1. Abhängigkeiten prüfen (git, python3)
echo "Prüfe Systemvoraussetzungen..."
for cmd in git python3; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Fehler: '$cmd' ist nicht installiert."
        exit 1
    fi
done

# 2. Repository klonen oder aktualisieren
if [ -d "$TARGET_DIR/.git" ]; then
    echo "Aktualisiere bestehendes Repository in $TARGET_DIR..."
    cd "$TARGET_DIR"
    git pull
else
    echo "Klone Repository nach $TARGET_DIR..."
    mkdir -p "$(dirname "$TARGET_DIR")"
    git clone "$REPO_URL" "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

# 3. Python Virtual Environment für Ansible einrichten
echo "Richte Ansible in einer Python-Sandbox (venv) ein..."
python3 -m venv venv
source venv/bin/activate

echo "Aktualisiere pip und installiere Ansible..."
pip install --upgrade pip
pip install ansible community.general

# 4. Ansible Playbook ausführen
echo "Starte Ansible Playbook..."
ansible-playbook playbook.yml

echo "=== Fertig! Das System-Setup wurde erfolgreich abgeschlossen. ==="
