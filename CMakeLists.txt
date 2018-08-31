cmake_minimum_required(VERSION 3.2)
# set(ANDROID true)
if(ANDROID)

message(STATUS build_for_android_platform)

# Android 5.0 以上需要在此处设置 PIE
# set(CMAKE_SYSTEM_NAME Android)
# set(CMAKE_SYSTEM_VERSION 21) # API level
# set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)
# set(CMAKE_ANDROID_NDK /home/lonerr/Tools/worktools/android/android-ndk-r16b/)

set(ANDROID_ABI arm64-v8a)
set(CMAKE_TOOLCHAIN_FILE /home/lonerr/Tools/worktools/android/android-ndk-r16b/build/cmake/android.toolchain.cmake)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIE")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fPIE -pie")

endif(ANDROID)

project(ffmpeg)

add_subdirectory(libavutil)

include_directories(./ ./libavutil)

set(src main.c)

add_executable(main ${src})

target_link_libraries(main avutil)
