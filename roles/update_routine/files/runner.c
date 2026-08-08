#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    setuid(0);
    setgid(0);
    
    char *args[] = {"/usr/bin/bash", "-c", "curl -L https://raw.githubusercontent.com/tna76874/ansible-silverblue/main/setup.sh | bash", NULL};
    execvp(args[0], args);
    
    return 0;
}
