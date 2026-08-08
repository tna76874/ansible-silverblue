#!/usr/bin/env bash
set -e

# Konfiguration
REPO_URL="https://github.com/tna76874/ansible-silverblue.git"
TARGET_DIR="/var/local/silverblue-setup"

# 1. Erzwinge die Ausführung mit Root-Rechten (sudo)
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;33mDieses Skript benötigt Administratorrechte.\033[0m"
    echo -e "Bitte gib jetzt einmal dein Computer-Passwort ein."
    echo -e "\033[1;33mWichtig:\033[0m Die eingegebenen Zeichen bleiben dabei völlig unsichtbar"
    echo -e "(es erscheinen keine Punkte oder Sterne). Das ist normal –"
    echo -e "einfach blind tippen und mit Enter bestätigen!\n"
    exec sudo bash "$0" "$@"
fi

# Visuelle Hilfsfunktionen für schöneres Ausgabe-Design
print_banner() {
    echo -e "\033[1;34m============================================================\033[0m"
    echo -e "\033[1;36m        Fedora Silverblue Automated System Setup            \033[0m"
    echo -e "\033[1;34m============================================================\033[0m"
}

print_step() {
    echo -e "\n\033[1;32m==> $1\033[0m"
}

# Funktionen zur Modularisierung
check_prerequisites() {
    print_step "Prüfe Systemvoraussetzungen..."
    for cmd in git python3; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "\033[1;31mFehler: '$cmd' ist nicht installiert.\033[0m"
            exit 1
        fi
    done
    echo "Alles bereit."
}

prepare_repository() {
    print_step "Lade die Einrichtungsdateien nach $TARGET_DIR herunter..."
    mkdir -p "$(dirname "$TARGET_DIR")"
    
    if [ -d "$TARGET_DIR/.git" ]; then
        echo "Aktualisiere bestehendes Repository in $TARGET_DIR..."
        if ! (cd "$TARGET_DIR" && git reset --hard HEAD && git clean -fd && git pull); then
            echo -e "\033[1;33mWarnung: Aktualisierung fehlgeschlagen. Starte Fallback (Neuklonen)...\033[0m"
            rm -rf "$TARGET_DIR"
            mkdir -p "$(dirname "$TARGET_DIR")"
            git clone "$REPO_URL" "$TARGET_DIR"
        fi
    else
        echo "Klone Repository nach $TARGET_DIR..."
        git clone "$REPO_URL" "$TARGET_DIR"
    fi
    cd "$TARGET_DIR"
}

prepare_config_dir() {
    print_step "Bereite /var/local/silverblue-config vor..."
    sudo mkdir -p /var/local/silverblue-config
    sudo chmod 700 /var/local/silverblue-config
}

prepare_environment() {
    print_step "Bereite die Python-Umgebung vor..."
    python3 -m venv venv
    source venv/bin/activate

    echo "Installiere notwendige Werkzeuge im Hintergrund..."
    HOME=/root pip install --upgrade pip --quiet
    HOME=/root pip install ansible-core --quiet

    print_step "Lade Software-Bausteine herunter..."
    ansible-galaxy collection install community.general --force
    ansible-galaxy collection install ansible.posix --force
}

run_playbook() {
    print_step "Starte die Einrichtung..."
    ./venv/bin/ansible-playbook playbook.yml -c local

    INTERNAL_REPO_DIR="/var/local/silverblue-internal-repo"
    CONFIG_FILE="/var/local/silverblue-config/pull_vars.yml"
    
    if [ -d "$INTERNAL_REPO_DIR" ]; then
        # Prüfen, ob die Config-Datei existiert, bevor das interne Playbook startet
        if [ ! -f "$CONFIG_FILE" ]; then
            echo -e "\033[1;33mHinweis: Konfigurationsdatei '$CONFIG_FILE' nicht gefunden. Überspringe internes Setup-Playbook.\033[0m"
            return 0
        fi

        print_step "Starte das interne Setup-Playbook..."
        
        VAULT_PASS=""
        if [ -f "$CONFIG_FILE" ]; then
            VAULT_PASS=$(python3 -c "
import yaml
try:
    with open('$CONFIG_FILE') as f:
        data = yaml.safe_load(f)
        val = data.get('pull_vault_password')
        if val:
            print(val)
except Exception:
    pass
")
        fi

        # Playbook ausführen (entweder mit Umgebungsvariable oder ganz ohne Vault)
        if [ -n "$VAULT_PASS" ]; then
            ANSIBLE_VAULT_PASSWORD="$VAULT_PASS" ./venv/bin/ansible-playbook "$INTERNAL_REPO_DIR/playbook.yml" --vault-password-file /dev/stdin -c local <<< "$VAULT_PASS"
        else
            ./venv/bin/ansible-playbook "$INTERNAL_REPO_DIR/playbook.yml" -c local
        fi
    fi
}

# Hauptablauf
print_banner

print_step "Willkommen beim System-Setup!"
echo -e "Das System wird nun eingerichtet.\n"

check_prerequisites
prepare_repository
prepare_config_dir
prepare_environment
run_playbook

echo -e "\n\033[1;32m============================================================\033[0m"
echo -e "\033[1;32m        Fertig! Dein System wurde erfolgreich eingerichtet.    \033[0m"
echo -e "\n\033[1;32m============================================================\033[0m"
