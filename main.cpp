#include "libavutil/adler32.h"
#include "libavutil/aes.h"
#include <iostream>
int main(int argc,char** argv){
    std::cout << "test adler32" << std::endl;
    uint8_t data[1];
    data[0] = 1;
    std::cout << av_adler32_update(1,data,1) << std::endl;

    struct AVAES *b;
    return 1;
}