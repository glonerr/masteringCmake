project(libavutil)

set(src adler32.c aes_ctr.c aes.c avstring.c bprint.c channel_layout.c cpu.c dict.c eval.c error.c fifo.c file_open.c log.c mathematics.c mem.c opt.c parseutils.c pixdesc.c reverse.c random_seed.c rational.c samplefmt.c sha.c time.c aarch64/cpu.c)

include_directories(../)

add_library(avutil SHARED ${src})