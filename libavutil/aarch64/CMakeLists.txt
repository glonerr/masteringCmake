project(libavutil_aarch64)

include_directories(../../)

set(src float_dsp_init.c float_dsp_neon.S)

add_library(libavutil_aarch64 OBJECT ${src})

set_target_properties("libavutil_aarch64" PROPERTIES COMPILE_FLAGS "-fno-integrated-as")