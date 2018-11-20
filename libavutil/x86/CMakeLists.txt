project(avutil_x86)

set(src cpu.c fixed_dsp_init.c float_dsp_init.c imgutils_init.c lls_init.c)

if(CONFIG_PIXELUTILS)
    set(src ${src} float_dsp_neon.S)
endif() 

enable_language(ASM)

include_directories(../)

add_library(avutil_aarch64 OBJECT ${src})

if(HAVE_NEON)
    set_target_properties("avutil_aarch64" PROPERTIES COMPILE_FLAGS "-fno-integrated-as")
endif()