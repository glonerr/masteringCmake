cmake_minimum_required(VERSION 3.3)
# set(ANDROID true)
if(ANDROID)
    # for cmake 3.7
    # set(CMAKE_SYSTEM_NAME Android)
    # set(CMAKE_SYSTEM_VERSION 21) # API level
    # set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)
    # set(CMAKE_ANDROID_NDK /home/lonerr/Tools/worktools/android/android-ndk-r16b/)

    # for cmake 3.2
    set(ANDROID_ABI arm64-v8a)
    set(CMAKE_TOOLCHAIN_FILE /home/lonerr/Tools/worktools/android/android-ndk-r16b/build/cmake/android.toolchain.cmake)
    set(arch aarch64)

    # Android 5.0 以上需要在此处设置 PIE
    # set(ANDROID_PIE ON)
    # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIE")
    # set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fPIE -pie")
endif(ANDROID)

add_definitions(-DHAVE_AV_CONFIG_H)

project(ffmpeg)

set(ARCH_LIST aarch64 alpha arm avr32 avr32_ap avr32_uc bfin ia64 m68k mips mips64 parisc ppc ppc64 s390 sh4 sparc sparc64 tilegx tilepro tomi x86 x86_32 x86_64)

set(ARCH_EXT_LIST_ARM armv5te armv6 armv6t2 armv8 neon vfp vfpv3 setend)

set(ARCH_EXT_LIST_MIPS mipsfpu mips32r2 mips32r5 mips64r2 mips32r6 mips64r6 mipsdsp mipsdspr2 msa)

set(ARCH_EXT_LIST_LOONGSON loongson2 loongson3 mmi)

set(ARCH_EXT_LIST_X86_SIMD aesni amd3dnow amd3dnowext avx avx2 avx512 fma3 fma4 mmx mmxext sse sse2 sse3 sse4 sse42 ssse3 xop)

set(ARCH_EXT_LIST_PPC altivec dcbzl ldbrx power8 ppc4xx vsx)

set(ARCH_EXT_LIST_X86 ${ARCH_EXT_LIST_X86_SIMD} cpunop i686)

set(ARCH_EXT_LIST ${ARCH_EXT_LIST_ARM} ${ARCH_EXT_LIST_PPC} ${ARCH_EXT_LIST_X86} ${ARCH_EXT_LIST_MIPS} ${ARCH_EXT_LIST_LOONGSON})

set(ARCH_FEATURES aligned_stack fast_64bit fast_clz fast_cmov local_aligned simd_align_16 simd_align_32 simd_align_64)

message("ARCH_EXT_LIST_ARM:" ${ARCH_EXT_LIST_ARM})
message("ARCH_EXT_LIST_MIPS:" ${ARCH_EXT_LIST_MIPS})
message("ARCH_EXT_LIST_LOONGSON:" ${ARCH_EXT_LIST_LOONGSON})
message("ARCH_EXT_LIST_X86_SIMD:" ${ARCH_EXT_LIST_X86_SIMD})
message("ARCH_EXT_LIST_PPC:" ${ARCH_EXT_LIST_PPC})
message("ARCH_EXT_LIST_X86:" ${ARCH_EXT_LIST_X86})
message("ARCH_EXT_LIST:" ${ARCH_EXT_LIST})
message("ARCH_FEATURES:" ${ARCH_FEATURES})

# init all arch variables with 0
foreach(item ${ARCH_LIST})
    string(TOUPPER "ARCH_${item}" ARCH)
    set(${ARCH} 0)
endforeach(item ${list})

# start config
# set default arch
if(NOT arch)
    set(arch ${CMAKE_SYSTEM_PROCESSOR})
endif(NOT arch)

if(${arch} MATCHES "(x86_64)|(x86_32)")
    set(ARCH_X86 1)
endif()

# set arch
string(TOUPPER "ARCH_${arch}" ARCH)
set(${ARCH} 1)

# create config.h
configure_file(config.h.in ../config.h)

add_subdirectory(libavutil)

include_directories(./ ./libavutil)

set(src libavutil/tests/aes_ctr.c)

add_executable(main ${src})

target_link_libraries(main avutil)
