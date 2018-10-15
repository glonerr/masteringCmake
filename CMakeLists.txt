cmake_minimum_required(VERSION 3.3)
# set(ANDROID true)
if(ANDROID)
    message("android build")
    # for cmake 3.7
    # set(CMAKE_SYSTEM_NAME Android)
    # set(CMAKE_SYSTEM_VERSION 21) # API level
    # set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)
    # set(CMAKE_ANDROID_NDK /home/lonerr/Tools/worktools/android/android-ndk-r17c/)

    # for cmake 3.2
    set(ANDROID_ABI arm64-v8a)
    set(CMAKE_TOOLCHAIN_FILE /home/lonerr/Tools/worktools/android/android-ndk-r17c/build/cmake/android.toolchain.cmake)
    set(arch aarch64)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-pointer-to-int-cast -Wstrict-prototypes -Wempty-body -Wno-parentheses -Wno-switch -Wno-format-zero-length -Wno-pointer-sign")

    # Android 5.0 以上需要在此处设置 PIE
    # set(ANDROID_PIE ON)
    # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIE")
    # set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fPIE -pie")
endif(ANDROID)

function(add_suffix suf list res_list)
    foreach(item ${list})
        list(APPEND res_list "${item}${suf}")
    endforeach(item ${list})
    set(${res_list} PARENT_SCOPE)
endfunction()

function(remove_suffix suf list res_list)
    foreach(item ${list})
        # string(REGEX REPLACE "${remove_suffix}" ":" new_item "${item}")
        string(REGEX REPLACE ${suf}\$ "" new_item "${item}")
        list(APPEND res_list ${new_item})
    endforeach(item ${list})
    set(${res_list} PARENT_SCOPE)
endfunction()

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

set(BUILTIN_LIST atomic_cas_ptr machine_rw_barrier MemoryBarrier mm_empty rdtsc sem_timedwait sync_val_compare_and_swap)

set(HAVE_LIST_CMDLINE inline_asm symver x86asm)

set(HAVE_LIST_PUB bigendian fast_unaligned)

set(HEADERS_LIST arpa_inet_h asm_types_h cdio_paranoia_h cdio_paranoia_paranoia_h cuda_h dispatch_dispatch_h dev_bktr_ioctl_bt848_h dev_bktr_ioctl_meteor_h dev_ic_bt8xx_h dev_video_bktr_ioctl_bt848_h dev_video_meteor_ioctl_meteor_h direct_h dirent_h dxgidebug_h dxva_h ES2_gl_h gsm_h io_h linux_perf_event_h machine_ioctl_bt848_h machine_ioctl_meteor_h malloc_h opencv2_core_core_c_h OpenGL_gl3_h poll_h sys_param_h sys_resource_h sys_select_h sys_soundcard_h sys_time_h sys_un_h sys_videoio_h termios_h udplite_h unistd_h valgrind_valgrind_h windows_h winsock2_h)

set(INTRINSICS_LIST intrinsics_neon)

set(COMPLEX_FUNCS cabs cexp)

set(MATH_FUNCS atanf atan2f cbrt cbrtf copysign cosf erf exp2 exp2f expf hypot isfinite isinf isnan ldexpf llrint llrintf log2 log2f log10f lrint lrintf powf rint round roundf sinf trunc truncf)

set(SYSTEM_FEATURES dos_paths libc_msvcrt MMAL_PARAMETER_VIDEO_MAX_NUM_CALLBACKS section_data_rel_ro threads uwp winrt)

set(SYSTEM_FUNCS access aligned_malloc arc4random clock_gettime closesocket CommandLineToArgvW fcntl getaddrinfo gethrtime getopt GetProcessAffinityMask GetProcessMemoryInfo GetProcessTimes getrusage GetSystemTimeAsFileTime gettimeofday glob glXGetProcAddress gmtime_r inet_aton isatty kbhit localtime_r lstat lzo1x_999_compress mach_absolute_time MapViewOfFile memalign mkstemp mmap mprotect nanosleep PeekNamedPipe posix_memalign pthread_cancel sched_getaffinity SecItemImport SetConsoleTextAttribute SetConsoleCtrlHandler setmode setrlimit Sleep strerror_r sysconf sysctl usleep UTGetOSTypeFromString VirtualAlloc wglGetProcAddress)

set(SYSTEM_LIBRARIES bcrypt vaapi_drm vaapi_x11 vdpau_x11)

set(TOOLCHAIN_FEATURES as_arch_directive as_dn_directive as_fpu_directive as_func as_object_arch asm_mod_q blocks_extension ebp_available ebx_available gnu_as gnu_windres ibm_asm inline_asm_direct_symbol_refs inline_asm_labels inline_asm_nonlocal_labels pragma_deprecated rsync_contimeout symver_asm_label symver_gnu_asm vfp_args xform_asm xmm_clobbers)

set(TYPES_LIST kCMVideoCodecType_HEVC socklen_t struct_addrinfo struct_group_source_req struct_ip_mreq_source struct_ipv6_mreq struct_msghdr_msg_flags struct_pollfd struct_rusage_ru_maxrss struct_sctp_event_subscribe struct_sockaddr_in6 struct_sockaddr_sa_len struct_sockaddr_storage struct_stat_st_mtim_tv_nsec struct_v4l2_frmivalenum_discrete)

add_suffix("_external" "${ARCH_EXT_LIST}" ARCH_EXT_LIST_EXTERNAL)
add_suffix("_inline" "${ARCH_EXT_LIST}" ARCH_EXT_LIST_INLINE)

set(HAVE_LIST ${ARCH_EXT_LIST} ${ARCH_EXT_LIST_EXTERNAL} ${ARCH_EXT_LIST_INLINE} ${ARCH_FEATURES} ${BUILTIN_LIST} ${COMPLEX_FUNCS} ${HAVE_LIST_CMDLINE} ${HAVE_LIST_PUB} ${HEADERS_LIST} ${INTRINSICS_LIST} ${MATH_FUNCS} ${SYSTEM_FEATURES} ${SYSTEM_FUNCS} ${SYSTEM_LIBRARIES} ${THREADS_LIST} ${TOOLCHAIN_FEATURES} ${TYPES_LIST} makeinfo makeinfo_html opencl_d3d11 opencl_drm_arm opencl_drm_beignet opencl_dxva2 opencl_vaapi_beignet opencl_vaapi_intel_media perl pod2man texi2html)

# message("ARCH_EXT_LIST_MIPS:" ${ARCH_EXT_LIST_MIPS})
# message("ARCH_EXT_LIST_LOONGSON:" ${ARCH_EXT_LIST_LOONGSON})
# message("ARCH_EXT_LIST_X86_SIMD:" ${ARCH_EXT_LIST_X86_SIMD})
# message("ARCH_EXT_LIST_PPC:" ${ARCH_EXT_LIST_PPC})
# message("ARCH_EXT_LIST_X86:" ${ARCH_EXT_LIST_X86})
# message("ARCH_EXT_LIST:" "${ARCH_EXT_LIST}")
# message("ARCH_FEATURES:" ${ARCH_FEATURES})
message("HAVE_LIST:" "${HAVE_LIST}")

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

include_directories(./)

set(src libavutil/tests/parseutils.c)

add_executable(main ${src})

target_link_libraries(main avutil)
