project(libavutil)

add_definitions(-DHAVE_AV_CONFIG_H)

set(src mem.c log.c bprint.c)

include_directories(./ ../)

add_library(avutil SHARED ${src})