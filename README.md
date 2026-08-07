# Fedora Silverblue System Setup

Automatisierte Einrichtung für Fedora Silverblue mit Ansible.

## 1. Installation von Fedora Silverblue
Lade dir das Betriebssystem von der offiziellen Website herunter und installiere es:
* [Fedora Silverblue Download & Anleitung](https://fedoraproject.org/atomic-desktops/silverblue/)

> **Empfehlung:** Aktiviere während der Installation unbedingt die **Festplattenverschlüsselung** (LUKS), um deine Daten abzusichern.

---

## 2. Einrichtung starten

1. Starte deinen neu installierten PC und schließe die Ersteinrichtung ab (Benutzerkonto anlegen).
2. Öffne das **Terminal**.
3. Führe folgenden Befehl aus, um die automatische Einrichtung zu starten:

```bash
curl -L [https://raw.githubusercontent.com/tna76874/ansible-silverblue/main/setup.sh](https://raw.githubusercontent.com/tna76874/ansible-silverblue/main/setup.sh) | bash

```
