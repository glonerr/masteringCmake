extern "C" {
#include "libavutil/avutil.h"
#include "libavutil/integer.h"
#include <SDL2/SDL.h>
#include "libavutil/rational.c"
}

#include <stdio.h>
#include <cstdlib>
#include <iostream>
#include <string>
using namespace std;

#define ff_ctzll(v) __builtin_ctzll(v)

int test_rational()
{
    AVRational a, b, r;
    int i, j, k;
    static const int64_t numlist[] = {
        INT64_MIN, INT64_MIN + 1, INT64_MAX, INT32_MIN, INT32_MAX, 1, 0, -1,
        123456789, INT32_MAX - 1, INT32_MAX + 1LL, UINT32_MAX - 1, UINT32_MAX, UINT32_MAX + 1LL};

    for (a.num = -2; a.num <= 2; a.num++)
    {
        for (a.den = -2; a.den <= 2; a.den++)
        {
            for (b.num = -2; b.num <= 2; b.num++)
            {
                for (b.den = -2; b.den <= 2; b.den++)
                {
                    int c = av_cmp_q(a, b);
                    double d = av_q2d(a) == av_q2d(b) ? 0 : (av_q2d(a) - av_q2d(b));
                    if (d > 0)
                        d = 1;
                    else if (d < 0)
                        d = -1;
                    else if (d != d)
                        d = INT_MIN;
                    if (c != d)
                        av_log(NULL, AV_LOG_ERROR, "%d/%d %d/%d, %d %f\n", a.num,
                               a.den, b.num, b.den, c, d);
                    r = av_sub_q(av_add_q(b, a), b);
                    if (b.den && (r.num * a.den != a.num * r.den || !r.num != !a.num || !r.den != !a.den))
                        av_log(NULL, AV_LOG_ERROR, "%d/%d ", r.num, r.den);
                }
            }
        }
    }

    for (i = 0; i < FF_ARRAY_ELEMS(numlist); i++)
    {
        int64_t a = numlist[i];

        for (j = 0; j < FF_ARRAY_ELEMS(numlist); j++)
        {
            int64_t b = numlist[j];
            if (b <= 0)
                continue;
            for (k = 0; k < FF_ARRAY_ELEMS(numlist); k++)
            {
                int64_t c = numlist[k];
                int64_t res;
                AVInteger ai;

                if (c <= 0)
                    continue;
                res = av_rescale_rnd(a, b, c, AV_ROUND_ZERO);

                ai = av_mul_i(av_int2i(a), av_int2i(b));
                ai = av_div_i(ai, av_int2i(c));

                if (av_cmp_i(ai, av_int2i(INT64_MAX)) > 0 && res == INT64_MIN)
                    continue;
                if (av_cmp_i(ai, av_int2i(INT64_MIN)) < 0 && res == INT64_MIN)
                    continue;
                if (av_cmp_i(ai, av_int2i(res)) == 0)
                    continue;

                // Special exception for INT64_MIN, remove this in case INT64_MIN is handled without off by 1 error
                if (av_cmp_i(ai, av_int2i(res - 1)) == 0 && a == INT64_MIN)
                    continue;

                av_log(NULL, AV_LOG_ERROR, "%" PRId64 " * %" PRId64 " / %" PRId64 " = %" PRId64 " or %" PRId64 "\n", a, b, c, res, av_i2int(ai));
            }
        }
    }

    for (a.num = 1; a.num <= 10; a.num++)
    {
        for (a.den = 1; a.den <= 10; a.den++)
        {
            if (av_gcd(a.num, a.den) > 1)
                continue;
            for (b.num = 1; b.num <= 10; b.num++)
            {
                for (b.den = 1; b.den <= 10; b.den++)
                {
                    int start;
                    if (av_gcd(b.num, b.den) > 1)
                        continue;
                    if (av_cmp_q(b, a) < 0)
                        continue;
                    for (start = 0; start < 10; start++)
                    {
                        int acc = start;
                        int i;

                        for (i = 0; i < 100; i++)
                        {
                            int exact = start + av_rescale_q(i + 1, b, a);
                            acc = av_add_stable(a, acc, b, 1);
                            if (FFABS(acc - exact) > 2)
                            {
                                av_log(NULL, AV_LOG_ERROR, "%d/%d %d/%d, %d %d\n", a.num,
                                       a.den, b.num, b.den, acc, exact);
                                return 1;
                            }
                        }
                    }
                }
            }
        }
    }

    for (a.den = 1; a.den < 0x100000000U / 3; a.den *= 3)
    {
        for (a.num = -1; a.num < (1 << 27); a.num += 1 + a.num / 100)
        {
            float f = av_int2float(av_q2intfloat(a));
            float f2 = av_q2d(a);
            if (fabs(f - f2) > fabs(f) / 5000000)
            {
                av_log(NULL, AV_LOG_ERROR, "%d/%d %f %f\n", a.num,
                       a.den, f, f2);
                return 1;
            }
        }
    }
    return 0;
}

int main(int argc, char **argv)
{
    cout << "start test" << endl;
    cout << "avutil_version:" << avutil_version() << endl;
    cout << "avutil_license:" << avutil_license() << endl;
    cout << "avutil_configuration:" << avutil_configuration() << endl;
    cout << "av_version_info:" << av_version_info() << endl;
    cout << "av_get_media_type_string:" << av_get_media_type_string(AVMEDIA_TYPE_VIDEO) << endl;
    cout << "av_get_picture_type_char:" << av_get_picture_type_char(AV_PICTURE_TYPE_B) << endl;
    cout << "av_x_if_null:" << av_x_if_null(NULL, NULL) << endl;
    cout << "av_int_list_length_for_size:" << av_int_list_length_for_size(8, NULL, 0) << endl;
    FILE *f = av_fopen_utf8("/home/lonerr/Downloads/GPD Win 2 - Thief (2014) - PC.mp4", "r");
    AVRational d = av_add_q(av_make_q(4, 3), av_make_q(6, 5));
    cout << "av_add_q:" << d.num << "/" << d.den << endl;
    cout << "av_gcd:" << av_gcd(65, 225) << endl;
    cout << "ff_ctzll:" << ff_ctzll(22500) << endl;
    // av_log(NULL, AV_LOG_INFO, "asdjfad:" + av_gcd(15, 225));
    test_rational();
    return 1;
}