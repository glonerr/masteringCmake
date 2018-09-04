// #include "libavutil/mem.h"
// #include "libavutil/timer.h"
// #include "libavutil/log.h"
#include "libavutil/adler32.h"
// #include "libavutil/random_seed.c"
#include <stdio.h>

#define N 256
#define F 2

#define LEN 7001

static volatile int checksum;

// typedef uint32_t (*random_seed_ptr_t)(void);

int main(int argc, char **argv)
{
    int i;
    uint8_t data[LEN];

    for (i = 0; i < LEN; i++)
        data[i] = ((i * i) >> 3) + 123 * i;

    if (argc > 1 && !strcmp(argv[1], "-t")) {
        for (i = 0; i < 1000; i++) {
            checksum = av_adler32_update(1, data, LEN);
        }
    } else {
        checksum = av_adler32_update(1, data, LEN);
    }

    printf("%X (expected 50E6E508)\n", checksum);
    return checksum == 0x50e6e508 ? 0 : 1;
}