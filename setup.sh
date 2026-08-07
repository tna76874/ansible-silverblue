#!/usr/bin/env bash
set -e

# Konfiguration
REPO_URL="https://github.com/tna76874/ansible-silverblue.git"
TARGET_DIR="$HOME/.local/share/silverblue-setup"

# Visuelle Hilfsfunktionen für schöneres Ausgabe-Design
print_banner() {
    echo -e "\033[1;34m============================================================\033[0m"
    echo -e "\033[1;36m       Fedora Silverblue Automated System Setup              \033[0m"
    echo -e "\033[1;34m============================================================\033[0m"
}

print_step() {
    echo -e "\n\033[1;32m==> $1\033[0m"
}

print_banner

# 1. Info für Laien und Vorab-Prüfung
print_step "Willkommen beim System-Setup!"
echo -e "Damit dein Computer gleich wie gewünscht eingerichtet werden kann,"
echo -e "benötigen wir einmal kurz deine Erlaubnis (dein Computer-Passwort)."
echo -e "Das ist das Passwort, mit dem du dich auch an deinem PC anmeldest.\n"

# 2. Abhängigkeiten prüfen (git, python3)
print_step "Prüfe Systemvoraussetzungen..."
for cmd in git python3; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\033[1;31mFehler: '$cmd' ist nicht installiert.\033[0m"
        exit 1
    fi
done
echo "Alles bereit."

# 3. Repository klonen oder aktualisieren
print_step "Lade die Einrichtungsdateien herunter..."
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

# 4. Python Virtual Environment für Ansible einrichten
print_step "Bereite die Installations-Umgebung vor..."
python3 -m venv venv
source venv/bin/activate

echo "Installiere notwendige Werkzeuge im Hintergrund..."
pip install --upgrade pip --quiet
pip install ansible-core --quiet

# 5. Notwendige Ansible-Collections installieren
print_step "Lade Software-Bausteine herunter..."
ansible-galaxy collection install community.general

# 6. Ansible Playbook ausführen (mit Hinweistext zur unsichtbaren Passworteingabe)
print_step "Starte die Einrichtung..."
echo -e "\033[1;33mWichtig:\033[0m Wenn gleich nach dem Passwort gefragt wird, bleiben die"
echo -e "eingegebenen Zeichen völlig unsichtbar (es erscheinen keine Punkte oder Sterne)."
echo -e "Das ist normal – einfach blind tippen und mit Enter bestätigen!\n"
ansible-playbook playbook.yml --ask-become-pass

echo -e "\n\033[1;32m============================================================\033[0m"
echo -e "\033[1;32m       Fertig! Dein System wurde erfolgreich eingerichtet.  \033[0m"
echo -e "\n\033[1;32m============================================================\033[0m"
