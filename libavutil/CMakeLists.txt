project(avutil)

set(src ${arch}/float_dsp_init.c ${arch}/float_dsp_neon.S)

message("ARCH_AARCH64:" ${ARCH_AARCH64} ${arch})

include_directories(../)

add_library(avutil SHARED ${src})

set_target_properties("avutil" PROPERTIES COMPILE_FLAGS "-fno-integrated-as")