cmake_minimum_required(VERSION 3.2)
project(ffmpeg)

function(add_suffix suffix list result)
    foreach(s ${list})
        list(APPEND result ${s}${suffix})
    endforeach(s ${list})
endfunction()

# CONFIG_LIST contains configurable options, while HAVE_LIST is for
# system-dependent things.

set(AVCODEC_COMPONENTS
    bsfs
    decoders
    encoders
    hwaccels
    parsers
)

set(AVDEVICE_COMPONENTS
    indevs
    outdevs
)

set(AVFILTER_COMPONENTS
    filters
)

set(AVFORMAT_COMPONENTS
    demuxers
    muxers
    protocols
)

set(COMPONENT_LIST
    ${AVCODEC_COMPONENTS}
    ${AVDEVICE_COMPONENTS}
    ${AVFILTER_COMPONENTS}
    ${AVFORMAT_COMPONENTS}
)

set(EXAMPLE_LIST
    avio_dir_cmd_example
    avio_reading_example
    decode_audio_example
    decode_video_example
    demuxing_decoding_example
    encode_audio_example
    encode_video_example
    extract_mvs_example
    filter_audio_example
    filtering_audio_example
    filtering_video_example
    http_multiclient_example
    hw_decode_example
    metadata_example
    muxing_example
    qsvdec_example
    remuxing_example
    resampling_audio_example
    scaling_video_example
    transcode_aac_example
    transcoding_example
    vaapi_encode_example
    vaapi_transcode_example
)

set(EXTERNAL_AUTODETECT_LIBRARY_LIST
    alsa
    appkit
    avfoundation
    bzlib
    coreimage
    iconv
    libxcb
    libxcb_shm
    libxcb_shape
    libxcb_xfixes
    lzma
    schannel
    sdl2
    securetransport
    sndio
    xlib
    zlib
)

set(EXTERNAL_LIBRARY_GPL_LIST
    avisynth
    frei0r
    libcdio
    librubberband
    libvidstab
    libx264
    libx265
    libxavs
    libxvid
)

set(EXTERNAL_LIBRARY_NONFREE_LIST
    decklink
    libndi_newtek
    libfdk_aac
    openssl
    libtls
)

set(EXTERNAL_LIBRARY_VERSION3_LIST
    gmp
    libopencore_amrnb
    libopencore_amrwb
    libvmaf
    libvo_amrwbenc
    rkmpp
)

set(EXTERNAL_LIBRARY_GPLV3_LIST
    libsmbclient
)

set(EXTERNAL_LIBRARY_LIST
    ${EXTERNAL_LIBRARY_GPL_LIST}
    ${EXTERNAL_LIBRARY_NONFREE_LIST}
    ${EXTERNAL_LIBRARY_VERSION3_LIST}
    ${EXTERNAL_LIBRARY_GPLV3_LIST}
    chromaprint
    gcrypt
    gnutls
    jni
    ladspa
    libass
    libbluray
    libbs2b
    libcaca
    libcelt
    libcodec2
    libdc1394
    libdrm
    libflite
    libfontconfig
    libfreetype
    libfribidi
    libgme
    libgsm
    libiec61883
    libilbc
    libjack
    libkvazaar
    libmodplug
    libmp3lame
    libmysofa
    libopencv
    libopenh264
    libopenjpeg
    libopenmpt
    libopus
    libpulse
    librsvg
    librtmp
    libshine
    libsmbclient
    libsnappy
    libsoxr
    libspeex
    libssh
    libtesseract
    libtheora
    libtwolame
    libv4l2
    libvorbis
    libvpx
    libwavpack
    libwebp
    libxml2
    libzimg
    libzmq
    libzvbi
    lv2
    mediacodec
    openal
    opengl
)

set(HWACCEL_AUTODETECT_LIBRARY_LIST
    amf
    audiotoolbox
    crystalhd
    cuda
    cuvid
    d3d11va
    dxva2
    ffnvcodec
    nvdec
    nvenc
    vaapi
    vdpau
    videotoolbox
    v4l2_m2m
    xvmc
)

# catchall list of things that require external libs to link
set(EXTRALIBS_LIST
    cpu_init
    cws2fws
)

set(HWACCEL_LIBRARY_NONFREE_LIST
    cuda_sdk
    libnpp
)

set(HWACCEL_LIBRARY_LIST
    ${HWACCEL_LIBRARY_NONFREE_LIST}
    libmfx
    mmal
    omx
    opencl
)

set(DOCUMENT_LIST
    doc
    htmlpages
    manpages
    podpages
    txtpages
)

set(FEATURE_LIST
    ftrapv
    gray
    hardcoded_tables
    omx_rpi
    runtime_cpudetect
    safe_bitstream_reader
    shared
    small
    static
    swscale_alpha
)

set(LIBRARY_LIST
    avcodec
    avdevice
    avfilter
    avformat
    avresample
    avutil
    postproc
    swresample
    swscale
)

set(LICENSE_LIST
    gpl
    nonfree
    version3
)

set(PROGRAM_LIST
    ffplay
    ffprobe
    ffmpeg
)

set(SUBSYSTEM_LIST
    dct
    dwt
    error_resilience
    faan
    fast_unaligned
    fft
    lsp
    lzo
    mdct
    pixelutils
    network
    rdft
)

# COMPONENT_LIST needs to come last to ensure correct dependency checking
set(CONFIG_LIST
    ${DOCUMENT_LIST}
    ${EXAMPLE_LIST}
    ${EXTERNAL_LIBRARY_LIST}
    ${EXTERNAL_AUTODETECT_LIBRARY_LIST}
    ${HWACCEL_LIBRARY_LIST}
    ${HWACCEL_AUTODETECT_LIBRARY_LIST}
    ${FEATURE_LIST}
    ${LICENSE_LIST}
    ${LIBRARY_LIST}
    ${PROGRAM_LIST}
    ${SUBSYSTEM_LIST}
    autodetect
    fontconfig
    linux_perf
    memory_poisoning
    neon_clobber_test
    ossfuzz
    pic
    thumb
    valgrind_backtrace
    xmm_clobber_test
    ${COMPONENT_LIST}
)

set(THREADS_LIST
    pthreads
    os2threads
    w32threads
)

set(ATOMICS_LIST
    atomics_gcc
    atomics_suncc
    atomics_win32
)

set(AUTODETECT_LIBS
    ${EXTERNAL_AUTODETECT_LIBRARY_LIST}
    ${HWACCEL_AUTODETECT_LIBRARY_LIST}
    ${THREADS_LIST}
)

set(ARCH_LIST
    aarch64
    alpha
    arm
    avr32
    avr32_ap
    avr32_uc
    bfin
    ia64
    m68k
    mips
    mips64
    parisc
    ppc
    ppc64
    s390
    sh4
    sparc
    sparc64
    tilegx
    tilepro
    tomi
    x86
    x86_32
    x86_64
)

set(ARCH_EXT_LIST_ARM
    armv5te
    armv6
    armv6t2
    armv8
    neon
    vfp
    vfpv3
    setend
)

set(ARCH_EXT_LIST_MIPS
    mipsfpu
    mips32r2
    mips32r5
    mips64r2
    mips32r6
    mips64r6
    mipsdsp
    mipsdspr2
    msa
)

set(ARCH_EXT_LIST_LOONGSON
    loongson2
    loongson3
    mmi
)

set(ARCH_EXT_LIST_X86_SIMD
    aesni
    amd3dnow
    amd3dnowext
    avx
    avx2
    avx512
    fma3
    fma4
    mmx
    mmxext
    sse
    sse2
    sse3
    sse4
    sse42
    ssse3
    xop
)

set(ARCH_EXT_LIST_PPC
    altivec
    dcbzl
    ldbrx
    power8
    ppc4xx
    vsx
)

set(ARCH_EXT_LIST_X86
    ${ARCH_EXT_LIST_X86_SIMD}
    cpunop
    i686
)

set(ARCH_EXT_LIST
    ${ARCH_EXT_LIST_ARM}
    ${ARCH_EXT_LIST_PPC}
    ${ARCH_EXT_LIST_X86}
    ${ARCH_EXT_LIST_MIPS}
    ${ARCH_EXT_LIST_LOONGSON}
)

set(ARCH_FEATURES
    aligned_stack
    fast_64bit
    fast_clz
    fast_cmov
    local_aligned
    simd_align_16
    simd_align_32
    simd_align_64
)

set(BUILTIN_LIST
    atomic_cas_ptr
    machine_rw_barrier
    MemoryBarrier
    mm_empty
    rdtsc
    sem_timedwait
    sync_val_compare_and_swap
)
set(HAVE_LIST_CMDLINE
    inline_asm
    symver
    x86asm
)

set(HAVE_LIST_PUB
    bigendian
    fast_unaligned
)

set(HEADERS_LIST
    arpa_inet_h
    asm_types_h
    cdio_paranoia_h
    cdio_paranoia_paranoia_h
    cuda_h
    dispatch_dispatch_h
    dev_bktr_ioctl_bt848_h
    dev_bktr_ioctl_meteor_h
    dev_ic_bt8xx_h
    dev_video_bktr_ioctl_bt848_h
    dev_video_meteor_ioctl_meteor_h
    direct_h
    dirent_h
    dxgidebug_h
    dxva_h
    ES2_gl_h
    gsm_h
    io_h
    machine_ioctl_bt848_h
    machine_ioctl_meteor_h
    malloc_h
    opencv2_core_core_c_h
    OpenGL_gl3_h
    poll_h
    sys_param_h
    sys_resource_h
    sys_select_h
    sys_soundcard_h
    sys_time_h
    sys_un_h
    sys_videoio_h
    termios_h
    udplite_h
    unistd_h
    valgrind_valgrind_h
    windows_h
    winsock2_h
)

set(INTRINSICS_LIST
    intrinsics_neon
)

set(COMPLEX_FUNCS
    cabs
    cexp
)

set(MATH_FUNCS
    atanf
    atan2f
    cbrt
    cbrtf
    copysign
    cosf
    erf
    exp2
    exp2f
    expf
    hypot
    isfinite
    isinf
    isnan
    ldexpf
    llrint
    llrintf
    log2
    log2f
    log10f
    lrint
    lrintf
    powf
    rint
    round
    roundf
    sinf
    trunc
    truncf
)

set(SYSTEM_FEATURES
    dos_paths
    libc_msvcrt
    MMAL_PARAMETER_VIDEO_MAX_NUM_CALLBACKS
    section_data_rel_ro
    threads
    uwp
    winrt
)

set(SYSTEM_FUNCS
    access
    aligned_malloc
    arc4random
    clock_gettime
    closesocket
    CommandLineToArgvW
    fcntl
    getaddrinfo
    gethrtime
    getopt
    GetProcessAffinityMask
    GetProcessMemoryInfo
    GetProcessTimes
    getrusage
    GetSystemTimeAsFileTime
    gettimeofday
    glob
    glXGetProcAddress
    gmtime_r
    inet_aton
    isatty
    kbhit
    localtime_r
    lstat
    lzo1x_999_compress
    mach_absolute_time
    MapViewOfFile
    memalign
    mkstemp
    mmap
    mprotect
    nanosleep
    PeekNamedPipe
    posix_memalign
    pthread_cancel
    sched_getaffinity
    SecItemImport
    SetConsoleTextAttribute
    SetConsoleCtrlHandler
    setmode
    setrlimit
    Sleep
    strerror_r
    sysconf
    sysctl
    usleep
    UTGetOSTypeFromString
    VirtualAlloc
    wglGetProcAddress
)

set(SYSTEM_LIBRARIES
    vaapi_drm
    vaapi_x11
    vdpau_x11
    wincrypt
)

set(TOOLCHAIN_FEATURES
    as_arch_directive
    as_fpu_directive
    as_func
    as_object_arch
    asm_mod_q
    blocks_extension
    ebp_available
    ebx_available
    gnu_as
    gnu_windres
    ibm_asm
    inline_asm_direct_symbol_refs
    inline_asm_labels
    inline_asm_nonlocal_labels
    pragma_deprecated
    rsync_contimeout
    symver_asm_label
    symver_gnu_asm
    vfp_args
    xform_asm
    xmm_clobbers
)

set(TYPES_LIST
    kCMVideoCodecType_HEVC
    socklen_t
    struct_addrinfo
    struct_group_source_req
    struct_ip_mreq_source
    struct_ipv6_mreq
    struct_msghdr_msg_flags
    struct_pollfd
    struct_rusage_ru_maxrss
    struct_sctp_event_subscribe
    struct_sockaddr_in6
    struct_sockaddr_sa_len
    struct_sockaddr_storage
    struct_stat_st_mtim_tv_nsec
    struct_v4l2_frmivalenum_discrete
)

set(EXTERNAL_LIST )
add_suffix(_external "${ARCH_EXT_LIST}" EXTERNAL_LIST)
set(INLINE_LIST )
add_suffix(_inline   "${ARCH_EXT_LIST}" INLINE_LIST)

foreach(s ${EXTERNAL_LIST})
    message(${s})
endforeach(s ${EXTERNAL_LIST})

# message(STATUS ${EXTERNAL_LIST})

set(HAVE_LIST
    ${ARCH_EXT_LIST}
    
    ${ARCH_FEATURES}
    ${BUILTIN_LIST}
    ${COMPLEX_FUNCS}
    ${HAVE_LIST_CMDLINE}
    ${HAVE_LIST_PUB}
    ${HEADERS_LIST}
    ${INTRINSICS_LIST}
    ${MATH_FUNCS}
    ${SYSTEM_FEATURES}
    ${SYSTEM_FUNCS}
    ${SYSTEM_LIBRARIES}
    ${THREADS_LIST}
    ${TOOLCHAIN_FEATURES}
    ${TYPES_LIST}
    makeinfo
    makeinfo_html
    opencl_d3d11
    opencl_drm_arm
    opencl_dxva2
    opencl_vaapi_beignet
    opencl_vaapi_intel_media
    perl
    pod2man
    texi2html
)

# options emitted with CONFIG_ prefix but not available on the command line
set(CONFIG_EXTRA
    aandcttables
    ac3dsp
    adts_header
    audio_frame_queue
    audiodsp
    blockdsp
    bswapdsp
    cabac
    cbs
    cbs_h264
    cbs_h265
    cbs_mpeg2
    dirac_parse
    dvprofile
    exif
    faandct
    faanidct
    fdctdsp
    flacdsp
    fmtconvert
    frame_thread_encoder
    g722dsp
    golomb
    gplv3
    h263dsp
    h264chroma
    h264dsp
    h264parse
    h264pred
    h264qpel
    hevcparse
    hpeldsp
    huffman
    huffyuvdsp
    huffyuvencdsp
    idctdsp
    iirfilter
    mdct15
    intrax8
    iso_media
    ividsp
    jpegtables
    lgplv3
    libx262
    llauddsp
    llviddsp
    llvidencdsp
    lpc
    lzf
    me_cmp
    mpeg_er
    mpegaudio
    mpegaudiodsp
    mpegaudioheader
    mpegvideo
    mpegvideoenc
    mss34dsp
    pixblockdsp
    qpeldsp
    qsv
    qsvdec
    qsvenc
    qsvvpp
    rangecoder
    riffdec
    riffenc
    rtpdec
    rtpenc_chain
    rv34dsp
    sinewin
    snappy
    srtp
    startcode
    texturedsp
    texturedspenc
    tpeldsp
    vaapi_1
    vaapi_encode
    vc1dsp
    videodsp
    vp3dsp
    vp56dsp
    vp8dsp
    wma_freqs
    wmv2dsp
)

set(CMDLINE_SELECT
    ${ARCH_EXT_LIST}
    ${CONFIG_LIST}
    ${HAVE_LIST_CMDLINE}
    ${THREADS_LIST}
    asm
    cross_compile
    debug
    extra_warnings
    logging
    lto
    optimizations
    rpath
    stripping
)

set(PATHS_LIST
    bindir
    datadir
    docdir
    incdir
    libdir
    mandir
    pkgconfigdir
    prefix
    shlibdir
    install_name_dir
)

set(CMDLINE_SET
    ${PATHS_LIST}
    ar
    arch
    as
    assert_level
    build_suffix
    cc
    objcc
    cpu
    cross_prefix
    custom_allocator
    cxx
    dep_cc
    doxygen
    env
    extra_version
    gas
    host_cc
    host_cflags
    host_extralibs
    host_ld
    host_ldflags
    host_os
    ignore_tests
    install
    ld
    ln_s
    logfile
    malloc_prefix
    nm
    optflags
    nvccflags
    pkg_config
    pkg_config_flags
    progs_suffix
    random_seed
    ranlib
    samples
    strip
    sws_max_filter_size
    sysinclude
    sysroot
    target_exec
    target_os
    target_path
    target_samples
    tempprefix
    toolchain
    valgrind
    x86asmexe
)

set(CMDLINE_APPEND
    extra_cflags
    extra_cxxflags
    extra_objcflags
    host_cppflags
)

# code dependency declarations

# architecture extensions

set(armv5te_deps arm)
set(armv6_deps arm)
set(armv6t2_deps arm)
set(armv8_deps aarch64)
set(neon_deps_any aarch64 arm)
set(intrinsics_neon_deps neon)
set(vfp_deps_any aarch64 arm)
set(vfpv3_deps vfp)
set(setend_deps arm)


set(altivec_deps ppc)
set(dcbzl_deps ppc)
set(ldbrx_deps ppc)
set(ppc4xx_deps ppc)
set(vsx_deps altivec)
set(power8_deps vsx)

set(loongson2_deps mips)
set(loongson3_deps mips)
set(mips32r2_deps mips)
set(mips32r5_deps mips)
set(mips32r6_deps mips)
set(mips64r2_deps mips)
set(mips64r6_deps mips)
set(mipsfpu_deps mips)
set(mipsdsp_deps mips)
set(mipsdspr2_deps mips)
set(mmi_deps mips)
set(msa_deps mipsfpu)

set(cpunop_deps i686)
set(x86_64_select i686)
set(x86_64_suggest fast_cmov)

set(amd3dnow_deps mmx)
set(amd3dnowext_deps amd3dnow)
set(i686_deps x86)
set(mmx_deps x86)
set(mmxext_deps mmx)
set(sse_deps mmxext)
set(sse2_deps sse)
set(sse3_deps sse2)
set(ssse3_deps sse3)
set(sse4_deps ssse3)
set(sse42_deps sse4)
set(aesni_deps sse42)
set(avx_deps sse42)
set(xop_deps avx)
set(fma3_deps avx)
set(fma4_deps avx)
set(avx2_deps avx)
set(avx512_deps avx2)

set(mmx_external_deps x86asm)
set(mmx_inline_deps inline_asm x86)
set(mmx_suggest mmx_external mmx_inline)

# foreach(s ${HAVE_LIST})
#     message(${s})
# endforeach()
# add_suffix(_external "${ARCH_EXT_LIST}")
