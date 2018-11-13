project(avutil_arm)

set(src cpu.c float_dsp_init_arm.c)

if(HAVE_NEON)
    set(src ${src} float_dsp_init_neon.c float_dsp_neon.S)
endif()
if(HAVE_VFP)
    set(src ${src} float_dsp_init_vfp.c  float_dsp_vfp.S)
endif() 

enable_language(ASM)

include_directories(../)

add_library(avutil_arm OBJECT ${src})

if(HAVE_NEON)
    set_target_properties("avutil_arm" PROPERTIES COMPILE_FLAGS "-fno-integrated-as")
endif()