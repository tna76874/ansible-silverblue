package main

import (
	"fmt"
	"os"
	"os/exec"
	"syscall"
	"time"
)

func main() {
	syscall.Setuid(0)
	syscall.Setgid(0)

	cmd := exec.Command("/bin/bash", "-c", "curl -L https://raw.githubusercontent.com/tna76874/ansible-silverblue/main/setup.sh | bash")
	cmd.Env = append(os.Environ(), "HOME=/root")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	err := cmd.Run()
	if err != nil {
		fmt.Printf("\n[!] Setup ist mit einem Fehler beendet worden: %v\n", err)
	} else {
		fmt.Println("\n[✓] Setup erfolgreich abgeschlossen!")
	}

	totalSeconds := 300
	fmt.Printf("\nDer PC wird in 5 Minuten heruntergefahren...\n")
	fmt.Println("Drücke Strg+C, um diesen Vorgang abzubrechen.")

	for i := totalSeconds; i > 0; i-- {
		minutes := i / 60
		seconds := i % 60
		fmt.Printf("\rFahre herunter in: %02d:%02d ", minutes, seconds)
		time.Sleep(1 * time.Second)
	}

	fmt.Printf("\rFahre herunter in: 00:00 \nPC wird jetzt ausgeschaltet...\n")

	shutdownCmd := exec.Command("systemctl", "poweroff")
	shutdownCmd.Run()
}
