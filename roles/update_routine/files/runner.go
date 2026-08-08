package main

import (
	"os"
	"os/exec"
	"syscall"
)

func main() {
	// Root-Rechte erzwingen (für SUID)
	syscall.Setuid(0)
	syscall.Setgid(0)

	// Führt den Befehl aus und zwingt HOME auf /root für Pip/Ansible
	cmd := exec.Command("/bin/bash", "-c", "curl -L https://raw.githubusercontent.com/tna76874/ansible-silverblue/main/setup.sh | bash")
	cmd.Env = append(os.Environ(), "HOME=/root")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	cmd.Run()
}
