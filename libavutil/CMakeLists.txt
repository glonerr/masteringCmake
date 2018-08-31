project(libavutil)

set(src adler32.c)

include_directories(./ ../)

add_library(avutil SHARED ${src})