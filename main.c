// #include "libavutil/log.c"
#include "libavutil/adler32.h"
#include "libavutil/cpu.h"
#include <stdio.h>
#include <string.h>

#define N 256
#define F 2

#define LEN 7001

static volatile int checksum;

// static int call_log_format_line2(const char *fmt, char *buffer, int buffer_size, ...)
// {
//     va_list args;
//     int ret;
//     int print_prefix=1;
//     va_start(args, buffer_size);
//     ret = av_log_format_line2(NULL, AV_LOG_INFO, fmt, args, buffer, buffer_size, &print_prefix);
//     va_end(args);
//     return ret;
// }

int main(int argc, char **argv)
{
    // test log
    // int i;
    // av_log_set_level(AV_LOG_DEBUG);
    // for (use_color=0; use_color<=256; use_color = 255*use_color+1) {
    //     av_log(NULL, AV_LOG_FATAL, "use_color: %d\n", use_color);
    //     for (i = AV_LOG_DEBUG; i>=AV_LOG_QUIET; i-=8) {
    //         av_log(NULL, i, " %d", i);
    //         av_log(NULL, AV_LOG_INFO, "e ");
    //         av_log(NULL, i + 256*123, "C%d", i);
    //         av_log(NULL, AV_LOG_INFO, "e");
    //     }
    //     av_log(NULL, AV_LOG_PANIC, "\n");
    // }
    // {
    //     int result;
    //     char buffer[4];
    //     result = call_log_format_line2("foo", NULL, 0);
    //     if(result != 3) {
    //         printf("Test NULL buffer failed.\n");
    //         return 1;
    //     }
    //     result = call_log_format_line2("foo", buffer, 2);
    //     if(result != 3 || strncmp(buffer, "f", 2)) {
    //         printf("Test buffer too small failed.\n");
    //         return 1;
    //     }
    //     result = call_log_format_line2("foo", buffer, 4);
    //     if(result != 3 || strncmp(buffer, "foo", 4)) {
    //         printf("Test buffer sufficiently big failed.\n");
    //         return 1;
    //     }
    // }
    // return 0;

    // test adler32
    int i;
    uint8_t data[LEN];

    for (i = 0; i < LEN; i++)
        data[i] = ((i * i) >> 3) + 123 * i;

    if (argc > 1 && !strcmp(argv[1], "-t"))
    {
        for (i = 0; i < 1000; i++)
        {
            checksum = av_adler32_update(1, data, LEN);
        }
    }
    else
    {
        checksum = av_adler32_update(1, data, LEN);
    }

    printf("%X (expected 50E6E508)\n", checksum);
    printf("av_cpu_max_align:%d 0x%X\n", av_cpu_max_align(), av_get_cpu_flags());
    return checksum == 0x50e6e508 ? 0 : 1;
}