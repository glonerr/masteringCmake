project(libavutil)

add_definitions(-DHAVE_AV_CONFIG_H)

set(src mem.c log.c bprint.c adler32.c error.c avstring.c intmath.c aes_ctr.c aes.c random_seed.c)

include_directories(./ ../)

add_library(avutil SHARED ${src})