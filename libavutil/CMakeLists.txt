project(libavutil)

set(src adler32.c log.c bprint.c mem.c fifo.c samplefmt.c aes_ctr.c aes.c parseutils.c eval.c reverse.c)

include_directories(./ ../)

add_library(avutil SHARED ${src})