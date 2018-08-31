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
    // uint8_t data[1];
    // data[0] = 1;

    // int i, j;
    // struct AVAES *b;
    // static const uint8_t rkey[2][16] = {
    //     {0},
    //     {0x10, 0xa5, 0x88, 0x69, 0xd7, 0x4b, 0xe5, 0xa3,
    //      0x74, 0xcf, 0x86, 0x7c, 0xfb, 0x47, 0x38, 0x59}};
    // static const uint8_t rpt[2][16] = {
    //     {0x6a, 0x84, 0x86, 0x7c, 0xd7, 0x7e, 0x12, 0xad,
    //      0x07, 0xea, 0x1b, 0xe8, 0x95, 0xc5, 0x3f, 0xa3},
    //     {0}};
    // static const uint8_t rct[2][16] = {
    //     {0x73, 0x22, 0x81, 0xc0, 0xa0, 0xaa, 0xb8, 0xf7,
    //      0xa5, 0x4a, 0x0c, 0x67, 0xa0, 0xc4, 0x5e, 0xcf},
    //     {0x6d, 0x25, 0x1e, 0x69, 0x44, 0xb0, 0x51, 0xe0,
    //      0x4e, 0xaa, 0x6f, 0xb4, 0xdb, 0xf7, 0x84, 0x65}};
    // uint8_t pt[32];
    // uint8_t temp[32];
    // uint8_t iv[2][16];
    // int err = 0;

    // b = av_aes_alloc();
    // if (!b)
    //     return 1;

    // void *b = av_malloc(10);
    // // int* cp = av_malloc(sizeof(int));
    // // *cp = 3;
    // // printf("0x%x,0x%x,%d",b,cp,*cp);
    // av_free(b);
    // // printf("0x%x,0x%x,%d",b,cp,*cp);

    // av_log(NULL, AV_LOG_DEBUG, "%X (expected 50E6E508)\n", checksum);
    checksum == 0x50e6e508 ? 0 : 1;

    int i, j, rsf, retry;
    int a = 0;
    int b = 0;
    // uint32_t seeds[N];
    // // random_seed_ptr_t random_seed[F] = {av_get_random_seed, get_generic_seed};

    // for (rsf=0; rsf<F; ++rsf){
    //     for (retry=0; retry<3; retry++){
    //         for (i=0; i<N; i++){
    //             // seeds[i] = random_seed[rsf]();
    //             for (j=0; j<i; j++)
    //                 if (seeds[j] == seeds[i])
    //                     goto retry;
    //         }
    //         printf("seeds OK\n");
    //         break;
    //         retry:;
    //     }
    //     if (retry >= 3) {
    //         printf("rsf %d: FAIL at %d with %X\n ", rsf, j, seeds[j]);
    //         return 1;
    //     }
    // }

    printf("test");
    return 1;
}