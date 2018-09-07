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

function(enable item)
    set(${item} 1 CACHE BOOL "")
endfunction(enable)

function(enable_all list)
    foreach(item ${list})
        string(TOUPPER "ARCH_${item}" ARCH)
        enable("${ARCH}")
    endforeach(item ${list})
endfunction(enable_all list)

function(disable item)
    set(${item} 0 CACHE Bool "")
endfunction(disable item)

function(disable_all list)
    foreach(item ${list})
        string(TOUPPER "ARCH_${item}" ARCH)
        disable("${ARCH}")
    endforeach(item ${list})
endfunction(disable_all list)

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

set(src main.c)

add_executable(main ${src})

target_link_libraries(main avutil)
