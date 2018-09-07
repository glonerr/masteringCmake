cmake_minimum_required(VERSION 3.2)
# set(ANDROID true)
set(arch x86_64)
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

function(print_list list)
    foreach(item ${list})
        message(STATUS ${item})
    endforeach(item ${list})
endfunction(print_list list)

function(set_arch arch arch_list)
    foreach(item ${arch_list})
        if(${arch} STREQUAL ${item})
            string(TOUPPER "ARCH_${item}" ARCH)
            enable("${ARCH}")
        else(${arch} STREQUAL ${item})
            string(TOUPPER "ARCH_${item}" ARCH)
            disable("${ARCH}")
        endif(${arch} STREQUAL ${item})
    endforeach(item ${list})
endfunction(set_arch arch)

function(enable item)
    set(${item} 1 CACHE BOOL "")
endfunction(enable)

function(enable_all item list)
    set(${item} 1 CACHE BOOL "")
endfunction(enable_all)

function(disable item)
    set(${item} 0 CACHE Bool "")
endfunction(disable item)

function(disable_all item list)
    set(${item} 0 CACHE Bool "")
endfunction(disable_all item)

set_arch(${arch} "${ARCH_LIST}")

configure_file(config.h.in ../config.h)

add_subdirectory(libavutil)

include_directories(./ ./libavutil)

set(src main.c)

add_executable(main ${src})

target_link_libraries(main avutil)
