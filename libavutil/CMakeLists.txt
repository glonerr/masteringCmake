project(libavutil)

set(src adler32.c log.c bprint.c mem.c fifo.c samplefmt.c aes_ctr.c aes.c parseutils.c eval.c reverse.c random_seed.c rational.c avstring.c avtime.c mathematics.c file_open.c sha.c)

include_directories(./ ../)

add_library(avutil SHARED ${src})