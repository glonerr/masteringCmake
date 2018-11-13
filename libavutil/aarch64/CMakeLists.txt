project(avutil_aarch64)

set(src cpu.c float_dsp_init.c)

if(HAVE_NEON)
    set(src ${src} float_dsp_neon.S)
endif() 

enable_language(ASM)

include_directories(../)

add_library(avutil_aarch64 OBJECT ${src})

if(HAVE_NEON)
    set_target_properties("avutil_aarch64" PROPERTIES COMPILE_FLAGS "-fno-integrated-as")
endif()