project(libavutil)

set(src adler32.c log.c bprint.c mem.c)

include_directories(./ ../)

add_library(avutil SHARED ${src})