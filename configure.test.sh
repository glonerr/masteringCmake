set_default() {
	for opt; do
		eval : \${$opt:=\$${opt}_default}
	done
}

is_in() {
	value=$1
	shift
	for var in $*; do
		[ $var = $value ] && return 0
	done
	return 1
}

warn() {
	log "WARNING: $*"
	WARNINGS="${WARNINGS}WARNING: $*\n"
}

die() {
	log "$@"
	echo "$error_color$bold_color$@$reset_color"
	cat <<EOF

If you think configure made a mistake, make sure you are using the latest
version from Git.  If the latest version fails, report the problem to the
ffmpeg-user@ffmpeg.org mailing list or IRC #ffmpeg on irc.freenode.net.
EOF
	if disabled logging; then
		cat <<EOF
Rerun configure with logging enabled (do not use --disable-logging), and
include the log this produces with your report.
EOF
	else
		cat <<EOF
Include the log file "$logfile" produced by configure as this will help
solve the problem.
EOF
	fi
	exit 1
}

# Avoid locale weirdness, besides we really just want to translate ASCII.
toupper() {
	echo "$@" | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}

tolower() {
	echo "$@" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}

c_escape() {
	echo "$*" | sed 's/["\\]/\\\0/g'
}

sh_quote() {
	v=$(echo "$1" | sed "s/'/'\\\\''/g")
	test "x$v" = "x${v#*[!A-Za-z0-9_/.+-]}" || v="'$v'"
	echo "$v"
}

cleanws() {
	echo "$@" | sed 's/^ *//;s/[[:space:]][[:space:]]*/ /g;s/ *$//'
}

filter() {
	pat=$1
	shift
	for v; do
		eval "case '$v' in $pat) printf '%s ' '$v' ;; esac"
	done
}

filter_out() {
	pat=$1
	shift
	for v; do
		eval "case '$v' in $pat) ;; *) printf '%s ' '$v' ;; esac"
	done
}

map() {
	m=$1
	shift
	for v; do eval $m; done
}

add_suffix() {
	suffix=$1
	shift
	for v; do echo ${v}${suffix}; done
}

remove_suffix() {
	suffix=$1
	shift
	for v; do echo ${v%$suffix}; done
}

arch=aarch64
arch_default=x86_64
cc_default=gcc
cc=clang

set_default arch

# CONFIG_LIST contains configurable options, while HAVE_LIST is for
# system-dependent things.

AVCODEC_COMPONENTS="
    bsfs
    decoders
    encoders
    hwaccels
    parsers
"

AVDEVICE_COMPONENTS="
    indevs
    outdevs
"

AVFILTER_COMPONENTS="
    filters
"

AVFORMAT_COMPONENTS="
    demuxers
    muxers
    protocols
"

COMPONENT_LIST="
    $AVCODEC_COMPONENTS
    $AVDEVICE_COMPONENTS
    $AVFILTER_COMPONENTS
    $AVFORMAT_COMPONENTS
"

EXAMPLE_LIST="
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
"

EXTERNAL_AUTODETECT_LIBRARY_LIST="
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
"

EXTERNAL_LIBRARY_GPL_LIST="
    avisynth
    frei0r
    libcdio
    libdavs2
    librubberband
    libvidstab
    libx264
    libx265
    libxavs
    libxavs2
    libxvid
"

EXTERNAL_LIBRARY_NONFREE_LIST="
    decklink
    libndi_newtek
    libfdk_aac
    openssl
    libtls
"

EXTERNAL_LIBRARY_VERSION3_LIST="
    gmp
    liblensfun
    libopencore_amrnb
    libopencore_amrwb
    libvmaf
    libvo_amrwbenc
    mbedtls
    rkmpp
"

EXTERNAL_LIBRARY_GPLV3_LIST="
    libsmbclient
"

EXTERNAL_LIBRARY_LIST="
    $EXTERNAL_LIBRARY_GPL_LIST
    $EXTERNAL_LIBRARY_NONFREE_LIST
    $EXTERNAL_LIBRARY_VERSION3_LIST
    $EXTERNAL_LIBRARY_GPLV3_LIST
    chromaprint
    gcrypt
    gnutls
    jni
    ladspa
    libaom
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
    libklvanc
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
    libsrt
    libssh
    libtensorflow
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
    vapoursynth
"

HWACCEL_AUTODETECT_LIBRARY_LIST="
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
"

# catchall list of things that require external libs to link
EXTRALIBS_LIST="
    cpu_init
    cws2fws
"

HWACCEL_LIBRARY_NONFREE_LIST="
    cuda_sdk
    libnpp
"

HWACCEL_LIBRARY_LIST="
    $HWACCEL_LIBRARY_NONFREE_LIST
    libmfx
    mmal
    omx
    opencl
"

DOCUMENT_LIST="
    doc
    htmlpages
    manpages
    podpages
    txtpages
"

FEATURE_LIST="
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
"

# this list should be kept in linking order
LIBRARY_LIST="
    avdevice
    avfilter
    swscale
    postproc
    avformat
    avcodec
    swresample
    avresample
    avutil
"

LICENSE_LIST="
    gpl
    nonfree
    version3
"

PROGRAM_LIST="
    ffplay
    ffprobe
    ffmpeg
"

SUBSYSTEM_LIST="
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
"

# COMPONENT_LIST needs to come last to ensure correct dependency checking
CONFIG_LIST="
    $DOCUMENT_LIST
    $EXAMPLE_LIST
    $EXTERNAL_LIBRARY_LIST
    $EXTERNAL_AUTODETECT_LIBRARY_LIST
    $HWACCEL_LIBRARY_LIST
    $HWACCEL_AUTODETECT_LIBRARY_LIST
    $FEATURE_LIST
    $LICENSE_LIST
    $LIBRARY_LIST
    $PROGRAM_LIST
    $SUBSYSTEM_LIST
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
    $COMPONENT_LIST
"

THREADS_LIST="
    pthreads
    os2threads
    w32threads
"

ATOMICS_LIST="
    atomics_gcc
    atomics_suncc
    atomics_win32
"

AUTODETECT_LIBS="
    $EXTERNAL_AUTODETECT_LIBRARY_LIST
    $HWACCEL_AUTODETECT_LIBRARY_LIST
    $THREADS_LIST
"

ARCH_LIST="
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
"

ARCH_EXT_LIST_ARM="
    armv5te
    armv6
    armv6t2
    armv8
    neon
    vfp
    vfpv3
    setend
"

ARCH_EXT_LIST_MIPS="
    mipsfpu
    mips32r2
    mips32r5
    mips64r2
    mips32r6
    mips64r6
    mipsdsp
    mipsdspr2
    msa
"

ARCH_EXT_LIST_LOONGSON="
    loongson2
    loongson3
    mmi
"

ARCH_EXT_LIST_X86_SIMD="
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
"

ARCH_EXT_LIST_PPC="
    altivec
    dcbzl
    ldbrx
    power8
    ppc4xx
    vsx
"

ARCH_EXT_LIST_X86="
    $ARCH_EXT_LIST_X86_SIMD
    cpunop
    i686
"

ARCH_EXT_LIST="
    $ARCH_EXT_LIST_ARM
    $ARCH_EXT_LIST_PPC
    $ARCH_EXT_LIST_X86
    $ARCH_EXT_LIST_MIPS
    $ARCH_EXT_LIST_LOONGSON
"

ARCH_FEATURES="
    aligned_stack
    fast_64bit
    fast_clz
    fast_cmov
    local_aligned
    simd_align_16
    simd_align_32
    simd_align_64
"

BUILTIN_LIST="
    atomic_cas_ptr
    machine_rw_barrier
    MemoryBarrier
    mm_empty
    rdtsc
    sem_timedwait
    sync_val_compare_and_swap
"
HAVE_LIST_CMDLINE="
    inline_asm
    symver
    x86asm
"

HAVE_LIST_PUB="
    bigendian
    fast_unaligned
"

HEADERS_LIST="
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
    linux_perf_event_h
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
"

INTRINSICS_LIST="
    intrinsics_neon
"

COMPLEX_FUNCS="
    cabs
    cexp
"

MATH_FUNCS="
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
"

SYSTEM_FEATURES="
    dos_paths
    libc_msvcrt
    MMAL_PARAMETER_VIDEO_MAX_NUM_CALLBACKS
    section_data_rel_ro
    threads
    uwp
    winrt
"

SYSTEM_FUNCS="
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
"

SYSTEM_LIBRARIES="
    bcrypt
    vaapi_drm
    vaapi_x11
    vdpau_x11
"

TOOLCHAIN_FEATURES="
    as_arch_directive
    as_dn_directive
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
"

TYPES_LIST="
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
"

HAVE_LIST="
    $ARCH_EXT_LIST
    $(add_suffix _external $ARCH_EXT_LIST)
    $(add_suffix _inline $ARCH_EXT_LIST)
    $ARCH_FEATURES
    $BUILTIN_LIST
    $COMPLEX_FUNCS
    $HAVE_LIST_CMDLINE
    $HAVE_LIST_PUB
    $HEADERS_LIST
    $INTRINSICS_LIST
    $MATH_FUNCS
    $SYSTEM_FEATURES
    $SYSTEM_FUNCS
    $SYSTEM_LIBRARIES
    $THREADS_LIST
    $TOOLCHAIN_FEATURES
    $TYPES_LIST
    makeinfo
    makeinfo_html
    opencl_d3d11
    opencl_drm_arm
    opencl_drm_beignet
    opencl_dxva2
    opencl_vaapi_beignet
    opencl_vaapi_intel_media
    perl
    pod2man
    texi2html
"

# options emitted with CONFIG_ prefix but not available on the command line
CONFIG_EXTRA="
    aandcttables
    ac3dsp
    adts_header
    audio_frame_queue
    audiodsp
    blockdsp
    bswapdsp
    cabac
    cbs
    cbs_av1
    cbs_h264
    cbs_h265
    cbs_jpeg
    cbs_mpeg2
    cbs_vp9
    dirac_parse
    dnn
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
"

CMDLINE_SELECT="
    $ARCH_EXT_LIST
    $CONFIG_LIST
    $HAVE_LIST_CMDLINE
    $THREADS_LIST
    asm
    cross_compile
    debug
    extra_warnings
    logging
    lto
    optimizations
    rpath
    stripping
"

PATHS_LIST="
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
"

CMDLINE_SET="
    $PATHS_LIST
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
    nvcc
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
"

CMDLINE_APPEND="
    extra_cflags
    extra_cxxflags
    extra_objcflags
    host_cppflags
"

# code dependency declarations

# architecture extensions

armv5te_deps="arm"
armv6_deps="arm"
armv6t2_deps="arm"
armv8_deps="aarch64"
neon_deps_any="aarch64 arm"
intrinsics_neon_deps="neon"
vfp_deps_any="aarch64 arm"
vfpv3_deps="vfp"
setend_deps="arm"

map 'eval ${v}_inline_deps=inline_asm' $ARCH_EXT_LIST_ARM

altivec_deps="ppc"
dcbzl_deps="ppc"
ldbrx_deps="ppc"
ppc4xx_deps="ppc"
vsx_deps="altivec"
power8_deps="vsx"

loongson2_deps="mips"
loongson3_deps="mips"
mips32r2_deps="mips"
mips32r5_deps="mips"
mips32r6_deps="mips"
mips64r2_deps="mips"
mips64r6_deps="mips"
mipsfpu_deps="mips"
mipsdsp_deps="mips"
mipsdspr2_deps="mips"
mmi_deps="mips"
msa_deps="mipsfpu"

cpunop_deps="i686"
x86_64_select="i686"
x86_64_suggest="fast_cmov"

amd3dnow_deps="mmx"
amd3dnowext_deps="amd3dnow"
i686_deps="x86"
mmx_deps="x86"
mmxext_deps="mmx"
sse_deps="mmxext"
sse2_deps="sse"
sse3_deps="sse2"
ssse3_deps="sse3"
sse4_deps="ssse3"
sse42_deps="sse4"
aesni_deps="sse42"
avx_deps="sse42"
xop_deps="avx"
fma3_deps="avx"
fma4_deps="avx"
avx2_deps="avx"
avx512_deps="avx2"

mmx_external_deps="x86asm"
mmx_inline_deps="inline_asm x86"
mmx_suggest="mmx_external mmx_inline"

for ext in $(filter_out mmx $ARCH_EXT_LIST_X86_SIMD); do
	eval dep=\$${ext}_deps
	eval ${ext}_external_deps='"${dep}_external"'
	eval ${ext}_inline_deps='"${dep}_inline"'
	eval ${ext}_suggest='"${ext}_external ${ext}_inline"'
done

aligned_stack_if_any="aarch64 ppc x86"
fast_64bit_if_any="aarch64 alpha ia64 mips64 parisc64 ppc64 sparc64 x86_64"
fast_clz_if_any="aarch64 alpha avr32 mips ppc x86"
fast_unaligned_if_any="aarch64 ppc x86"
simd_align_16_if_any="altivec neon sse"
simd_align_32_if_any="avx"
simd_align_64_if_any="avx512"

# system capabilities
linux_perf_deps="linux_perf_event_h"
symver_if_any="symver_asm_label symver_gnu_asm"
valgrind_backtrace_conflict="optimizations"
valgrind_backtrace_deps="valgrind_valgrind_h"

# threading support
atomics_gcc_if="sync_val_compare_and_swap"
atomics_suncc_if="atomic_cas_ptr machine_rw_barrier"
atomics_win32_if="MemoryBarrier"
atomics_native_if_any="$ATOMICS_LIST"
w32threads_deps="atomics_native"
threads_if_any="$THREADS_LIST"

# subsystems
cbs_av1_select="cbs"
cbs_h264_select="cbs golomb"
cbs_h265_select="cbs golomb"
cbs_jpeg_select="cbs"
cbs_mpeg2_select="cbs"
cbs_vp9_select="cbs"
dct_select="rdft"
dirac_parse_select="golomb"
dnn_suggest="libtensorflow"
error_resilience_select="me_cmp"
faandct_deps="faan"
faandct_select="fdctdsp"
faanidct_deps="faan"
faanidct_select="idctdsp"
h264dsp_select="startcode"
hevcparse_select="golomb"
frame_thread_encoder_deps="encoders threads"
intrax8_select="blockdsp idctdsp"
mdct_select="fft"
mdct15_select="fft"
me_cmp_select="fdctdsp idctdsp pixblockdsp"
mpeg_er_select="error_resilience"
mpegaudio_select="mpegaudiodsp mpegaudioheader"
mpegaudiodsp_select="dct"
mpegvideo_select="blockdsp h264chroma hpeldsp idctdsp me_cmp mpeg_er videodsp"
mpegvideoenc_select="aandcttables me_cmp mpegvideo pixblockdsp qpeldsp"
vc1dsp_select="h264chroma qpeldsp startcode"
rdft_select="fft"

# decoders / encoders
aac_decoder_select="adts_header mdct15 mdct sinewin"
aac_fixed_decoder_select="adts_header mdct sinewin"
aac_encoder_select="audio_frame_queue iirfilter lpc mdct sinewin"
aac_latm_decoder_select="aac_decoder aac_latm_parser"
ac3_decoder_select="ac3_parser ac3dsp bswapdsp fmtconvert mdct"
ac3_fixed_decoder_select="ac3_parser ac3dsp bswapdsp mdct"
ac3_encoder_select="ac3dsp audiodsp mdct me_cmp"
ac3_fixed_encoder_select="ac3dsp audiodsp mdct me_cmp"
adpcm_g722_decoder_select="g722dsp"
adpcm_g722_encoder_select="g722dsp"
aic_decoder_select="golomb idctdsp"
alac_encoder_select="lpc"
als_decoder_select="bswapdsp"
amrnb_decoder_select="lsp"
amrwb_decoder_select="lsp"
amv_decoder_select="sp5x_decoder exif"
amv_encoder_select="jpegtables mpegvideoenc"
ape_decoder_select="bswapdsp llauddsp"
apng_decoder_deps="zlib"
apng_encoder_deps="zlib"
apng_encoder_select="llvidencdsp"
aptx_decoder_select="audio_frame_queue"
aptx_encoder_select="audio_frame_queue"
aptx_hd_decoder_select="audio_frame_queue"
aptx_hd_encoder_select="audio_frame_queue"
asv1_decoder_select="blockdsp bswapdsp idctdsp"
asv1_encoder_select="aandcttables bswapdsp fdctdsp pixblockdsp"
asv2_decoder_select="blockdsp bswapdsp idctdsp"
asv2_encoder_select="aandcttables bswapdsp fdctdsp pixblockdsp"
atrac1_decoder_select="mdct sinewin"
atrac3_decoder_select="mdct"
atrac3p_decoder_select="mdct sinewin"
atrac9_decoder_select="mdct"
avrn_decoder_select="exif jpegtables"
bink_decoder_select="blockdsp hpeldsp"
binkaudio_dct_decoder_select="mdct rdft dct sinewin wma_freqs"
binkaudio_rdft_decoder_select="mdct rdft sinewin wma_freqs"
cavs_decoder_select="blockdsp golomb h264chroma idctdsp qpeldsp videodsp"
clearvideo_decoder_select="idctdsp"
cllc_decoder_select="bswapdsp"
comfortnoise_encoder_select="lpc"
cook_decoder_select="audiodsp mdct sinewin"
cscd_decoder_select="lzo"
cscd_decoder_suggest="zlib"
dca_decoder_select="mdct"
dds_decoder_select="texturedsp"
dirac_decoder_select="dirac_parse dwt golomb videodsp mpegvideoenc"
dnxhd_decoder_select="blockdsp idctdsp"
dnxhd_encoder_select="blockdsp fdctdsp idctdsp mpegvideoenc pixblockdsp"
dolby_e_decoder_select="mdct"
dvvideo_decoder_select="dvprofile idctdsp"
dvvideo_encoder_select="dvprofile fdctdsp me_cmp pixblockdsp"
dxa_decoder_deps="zlib"
dxv_decoder_select="lzf texturedsp"
eac3_decoder_select="ac3_decoder"
eac3_encoder_select="ac3_encoder"
eamad_decoder_select="aandcttables blockdsp bswapdsp idctdsp mpegvideo"
eatgq_decoder_select="aandcttables"
eatqi_decoder_select="aandcttables blockdsp bswapdsp idctdsp"
exr_decoder_deps="zlib"
ffv1_decoder_select="rangecoder"
ffv1_encoder_select="rangecoder"
ffvhuff_decoder_select="huffyuv_decoder"
ffvhuff_encoder_select="huffyuv_encoder"
fic_decoder_select="golomb"
flac_decoder_select="flacdsp"
flac_encoder_select="bswapdsp flacdsp lpc"
flashsv2_decoder_deps="zlib"
flashsv2_encoder_deps="zlib"
flashsv_decoder_deps="zlib"
flashsv_encoder_deps="zlib"
flv_decoder_select="h263_decoder"
flv_encoder_select="h263_encoder"
fourxm_decoder_select="blockdsp bswapdsp"
fraps_decoder_select="bswapdsp huffman"
g2m_decoder_deps="zlib"
g2m_decoder_select="blockdsp idctdsp jpegtables"
g729_decoder_select="audiodsp"
h261_decoder_select="mpegvideo"
h261_encoder_select="mpegvideoenc"
h263_decoder_select="h263_parser h263dsp mpegvideo qpeldsp"
h263_encoder_select="h263dsp mpegvideoenc"
h263i_decoder_select="h263_decoder"
h263p_decoder_select="h263_decoder"
h263p_encoder_select="h263_encoder"
h264_decoder_select="cabac golomb h264chroma h264dsp h264parse h264pred h264qpel videodsp"
h264_decoder_suggest="error_resilience"
hap_decoder_select="snappy texturedsp"
hap_encoder_deps="libsnappy"
hap_encoder_select="texturedspenc"
hevc_decoder_select="bswapdsp cabac golomb hevcparse videodsp"
huffyuv_decoder_select="bswapdsp huffyuvdsp llviddsp"
huffyuv_encoder_select="bswapdsp huffman huffyuvencdsp llvidencdsp"
iac_decoder_select="imc_decoder"
imc_decoder_select="bswapdsp fft mdct sinewin"
indeo3_decoder_select="hpeldsp"
indeo4_decoder_select="ividsp"
indeo5_decoder_select="ividsp"
interplay_video_decoder_select="hpeldsp"
jpegls_decoder_select="mjpeg_decoder"
jv_decoder_select="blockdsp"
lagarith_decoder_select="llviddsp"
ljpeg_encoder_select="idctdsp jpegtables mpegvideoenc"
magicyuv_decoder_select="llviddsp"
magicyuv_encoder_select="llvidencdsp"
mdec_decoder_select="blockdsp idctdsp mpegvideo"
metasound_decoder_select="lsp mdct sinewin"
mimic_decoder_select="blockdsp bswapdsp hpeldsp idctdsp"
mjpeg_decoder_select="blockdsp hpeldsp exif idctdsp jpegtables"
mjpeg_encoder_select="jpegtables mpegvideoenc"
mjpegb_decoder_select="mjpeg_decoder"
mlp_decoder_select="mlp_parser"
mlp_encoder_select="lpc"
motionpixels_decoder_select="bswapdsp"
mp1_decoder_select="mpegaudio"
mp1float_decoder_select="mpegaudio"
mp2_decoder_select="mpegaudio"
mp2float_decoder_select="mpegaudio"
mp3_decoder_select="mpegaudio"
mp3adu_decoder_select="mpegaudio"
mp3adufloat_decoder_select="mpegaudio"
mp3float_decoder_select="mpegaudio"
mp3on4_decoder_select="mpegaudio"
mp3on4float_decoder_select="mpegaudio"
mpc7_decoder_select="bswapdsp mpegaudiodsp"
mpc8_decoder_select="mpegaudiodsp"
mpegvideo_decoder_select="mpegvideo"
mpeg1video_decoder_select="mpegvideo"
mpeg1video_encoder_select="mpegvideoenc h263dsp"
mpeg2video_decoder_select="mpegvideo"
mpeg2video_encoder_select="mpegvideoenc h263dsp"
mpeg4_decoder_select="h263_decoder mpeg4video_parser"
mpeg4_encoder_select="h263_encoder"
msa1_decoder_select="mss34dsp"
mscc_decoder_deps="zlib"
msmpeg4v1_decoder_select="h263_decoder"
msmpeg4v2_decoder_select="h263_decoder"
msmpeg4v2_encoder_select="h263_encoder"
msmpeg4v3_decoder_select="h263_decoder"
msmpeg4v3_encoder_select="h263_encoder"
mss2_decoder_select="mpegvideo qpeldsp vc1_decoder"
mts2_decoder_select="mss34dsp"
mwsc_decoder_deps="zlib"
mxpeg_decoder_select="mjpeg_decoder"
nellymoser_decoder_select="mdct sinewin"
nellymoser_encoder_select="audio_frame_queue mdct sinewin"
nuv_decoder_select="idctdsp lzo"
on2avc_decoder_select="mdct"
opus_decoder_deps="swresample"
opus_decoder_select="mdct15"
opus_encoder_select="audio_frame_queue mdct15"
png_decoder_deps="zlib"
png_encoder_deps="zlib"
png_encoder_select="llvidencdsp"
prores_decoder_select="blockdsp idctdsp"
prores_encoder_select="fdctdsp"
qcelp_decoder_select="lsp"
qdm2_decoder_select="mdct rdft mpegaudiodsp"
ra_144_decoder_select="audiodsp"
ra_144_encoder_select="audio_frame_queue lpc audiodsp"
ralf_decoder_select="golomb"
rasc_decoder_deps="zlib"
rawvideo_decoder_select="bswapdsp"
rscc_decoder_deps="zlib"
rtjpeg_decoder_select="me_cmp"
rv10_decoder_select="h263_decoder"
rv10_encoder_select="h263_encoder"
rv20_decoder_select="h263_decoder"
rv20_encoder_select="h263_encoder"
rv30_decoder_select="golomb h264pred h264qpel mpegvideo rv34dsp"
rv40_decoder_select="golomb h264pred h264qpel mpegvideo rv34dsp"
screenpresso_decoder_deps="zlib"
shorten_decoder_select="bswapdsp"
sipr_decoder_select="lsp"
snow_decoder_select="dwt h264qpel hpeldsp me_cmp rangecoder videodsp"
snow_encoder_select="dwt h264qpel hpeldsp me_cmp mpegvideoenc rangecoder"
sonic_decoder_select="golomb rangecoder"
sonic_encoder_select="golomb rangecoder"
sonic_ls_encoder_select="golomb rangecoder"
sp5x_decoder_select="mjpeg_decoder"
speedhq_decoder_select="mpegvideo"
srgc_decoder_deps="zlib"
svq1_decoder_select="hpeldsp"
svq1_encoder_select="hpeldsp me_cmp mpegvideoenc"
svq3_decoder_select="golomb h264dsp h264parse h264pred hpeldsp tpeldsp videodsp"
svq3_decoder_suggest="zlib"
tak_decoder_select="audiodsp"
tdsc_decoder_deps="zlib"
tdsc_decoder_select="mjpeg_decoder"
theora_decoder_select="vp3_decoder"
thp_decoder_select="mjpeg_decoder"
tiff_decoder_suggest="zlib lzma"
tiff_encoder_suggest="zlib"
truehd_decoder_select="mlp_parser"
truehd_encoder_select="lpc"
truemotion2_decoder_select="bswapdsp"
truespeech_decoder_select="bswapdsp"
tscc_decoder_deps="zlib"
twinvq_decoder_select="mdct lsp sinewin"
txd_decoder_select="texturedsp"
utvideo_decoder_select="bswapdsp llviddsp"
utvideo_encoder_select="bswapdsp huffman llvidencdsp"
vble_decoder_select="llviddsp"
vc1_decoder_select="blockdsp h263_decoder h264qpel intrax8 mpegvideo vc1dsp"
vc1image_decoder_select="vc1_decoder"
vorbis_decoder_select="mdct"
vorbis_encoder_select="audio_frame_queue mdct"
vp3_decoder_select="hpeldsp vp3dsp videodsp"
vp5_decoder_select="h264chroma hpeldsp videodsp vp3dsp vp56dsp"
vp6_decoder_select="h264chroma hpeldsp huffman videodsp vp3dsp vp56dsp"
vp6a_decoder_select="vp6_decoder"
vp6f_decoder_select="vp6_decoder"
vp7_decoder_select="h264pred videodsp vp8dsp"
vp8_decoder_select="h264pred videodsp vp8dsp"
vp9_decoder_select="videodsp vp9_parser vp9_superframe_split_bsf"
wcmv_decoder_deps="zlib"
webp_decoder_select="vp8_decoder exif"
wmalossless_decoder_select="llauddsp"
wmapro_decoder_select="mdct sinewin wma_freqs"
wmav1_decoder_select="mdct sinewin wma_freqs"
wmav1_encoder_select="mdct sinewin wma_freqs"
wmav2_decoder_select="mdct sinewin wma_freqs"
wmav2_encoder_select="mdct sinewin wma_freqs"
wmavoice_decoder_select="lsp rdft dct mdct sinewin"
wmv1_decoder_select="h263_decoder"
wmv1_encoder_select="h263_encoder"
wmv2_decoder_select="blockdsp error_resilience h263_decoder idctdsp intrax8 videodsp wmv2dsp"
wmv2_encoder_select="h263_encoder wmv2dsp"
wmv3_decoder_select="vc1_decoder"
wmv3image_decoder_select="wmv3_decoder"
xma1_decoder_select="wmapro_decoder"
xma2_decoder_select="wmapro_decoder"
zerocodec_decoder_deps="zlib"
zlib_decoder_deps="zlib"
zlib_encoder_deps="zlib"
zmbv_decoder_deps="zlib"
zmbv_encoder_deps="zlib"

# hardware accelerators
crystalhd_deps="libcrystalhd_libcrystalhd_if_h"
cuda_deps="ffnvcodec"
cuvid_deps="ffnvcodec"
d3d11va_deps="dxva_h ID3D11VideoDecoder ID3D11VideoContext"
dxva2_deps="dxva2api_h DXVA2_ConfigPictureDecode ole32 user32"
ffnvcodec_deps_any="libdl LoadLibrary"
nvdec_deps="ffnvcodec"
videotoolbox_hwaccel_deps="videotoolbox pthreads"
videotoolbox_hwaccel_extralibs="-framework QuartzCore"
xvmc_deps="X11_extensions_XvMClib_h"

h263_vaapi_hwaccel_deps="vaapi"
h263_vaapi_hwaccel_select="h263_decoder"
h263_videotoolbox_hwaccel_deps="videotoolbox"
h263_videotoolbox_hwaccel_select="h263_decoder"
h264_d3d11va_hwaccel_deps="d3d11va"
h264_d3d11va_hwaccel_select="h264_decoder"
h264_d3d11va2_hwaccel_deps="d3d11va"
h264_d3d11va2_hwaccel_select="h264_decoder"
h264_dxva2_hwaccel_deps="dxva2"
h264_dxva2_hwaccel_select="h264_decoder"
h264_nvdec_hwaccel_deps="nvdec"
h264_nvdec_hwaccel_select="h264_decoder"
h264_vaapi_hwaccel_deps="vaapi"
h264_vaapi_hwaccel_select="h264_decoder"
h264_vdpau_hwaccel_deps="vdpau"
h264_vdpau_hwaccel_select="h264_decoder"
h264_videotoolbox_hwaccel_deps="videotoolbox"
h264_videotoolbox_hwaccel_select="h264_decoder"
hevc_d3d11va_hwaccel_deps="d3d11va DXVA_PicParams_HEVC"
hevc_d3d11va_hwaccel_select="hevc_decoder"
hevc_d3d11va2_hwaccel_deps="d3d11va DXVA_PicParams_HEVC"
hevc_d3d11va2_hwaccel_select="hevc_decoder"
hevc_dxva2_hwaccel_deps="dxva2 DXVA_PicParams_HEVC"
hevc_dxva2_hwaccel_select="hevc_decoder"
hevc_nvdec_hwaccel_deps="nvdec"
hevc_nvdec_hwaccel_select="hevc_decoder"
hevc_vaapi_hwaccel_deps="vaapi VAPictureParameterBufferHEVC"
hevc_vaapi_hwaccel_select="hevc_decoder"
hevc_vdpau_hwaccel_deps="vdpau VdpPictureInfoHEVC"
hevc_vdpau_hwaccel_select="hevc_decoder"
hevc_videotoolbox_hwaccel_deps="videotoolbox"
hevc_videotoolbox_hwaccel_select="hevc_decoder"
mjpeg_nvdec_hwaccel_deps="nvdec"
mjpeg_nvdec_hwaccel_select="mjpeg_decoder"
mjpeg_vaapi_hwaccel_deps="vaapi"
mjpeg_vaapi_hwaccel_select="mjpeg_decoder"
mpeg_xvmc_hwaccel_deps="xvmc"
mpeg_xvmc_hwaccel_select="mpeg2video_decoder"
mpeg1_nvdec_hwaccel_deps="nvdec"
mpeg1_nvdec_hwaccel_select="mpeg1video_decoder"
mpeg1_vdpau_hwaccel_deps="vdpau"
mpeg1_vdpau_hwaccel_select="mpeg1video_decoder"
mpeg1_videotoolbox_hwaccel_deps="videotoolbox"
mpeg1_videotoolbox_hwaccel_select="mpeg1video_decoder"
mpeg1_xvmc_hwaccel_deps="xvmc"
mpeg1_xvmc_hwaccel_select="mpeg1video_decoder"
mpeg2_d3d11va_hwaccel_deps="d3d11va"
mpeg2_d3d11va_hwaccel_select="mpeg2video_decoder"
mpeg2_d3d11va2_hwaccel_deps="d3d11va"
mpeg2_d3d11va2_hwaccel_select="mpeg2video_decoder"
mpeg2_dxva2_hwaccel_deps="dxva2"
mpeg2_dxva2_hwaccel_select="mpeg2video_decoder"
mpeg2_nvdec_hwaccel_deps="nvdec"
mpeg2_nvdec_hwaccel_select="mpeg2video_decoder"
mpeg2_vaapi_hwaccel_deps="vaapi"
mpeg2_vaapi_hwaccel_select="mpeg2video_decoder"
mpeg2_vdpau_hwaccel_deps="vdpau"
mpeg2_vdpau_hwaccel_select="mpeg2video_decoder"
mpeg2_videotoolbox_hwaccel_deps="videotoolbox"
mpeg2_videotoolbox_hwaccel_select="mpeg2video_decoder"
mpeg2_xvmc_hwaccel_deps="xvmc"
mpeg2_xvmc_hwaccel_select="mpeg2video_decoder"
mpeg4_nvdec_hwaccel_deps="nvdec"
mpeg4_nvdec_hwaccel_select="mpeg4_decoder"
mpeg4_vaapi_hwaccel_deps="vaapi"
mpeg4_vaapi_hwaccel_select="mpeg4_decoder"
mpeg4_vdpau_hwaccel_deps="vdpau"
mpeg4_vdpau_hwaccel_select="mpeg4_decoder"
mpeg4_videotoolbox_hwaccel_deps="videotoolbox"
mpeg4_videotoolbox_hwaccel_select="mpeg4_decoder"
vc1_d3d11va_hwaccel_deps="d3d11va"
vc1_d3d11va_hwaccel_select="vc1_decoder"
vc1_d3d11va2_hwaccel_deps="d3d11va"
vc1_d3d11va2_hwaccel_select="vc1_decoder"
vc1_dxva2_hwaccel_deps="dxva2"
vc1_dxva2_hwaccel_select="vc1_decoder"
vc1_nvdec_hwaccel_deps="nvdec"
vc1_nvdec_hwaccel_select="vc1_decoder"
vc1_vaapi_hwaccel_deps="vaapi"
vc1_vaapi_hwaccel_select="vc1_decoder"
vc1_vdpau_hwaccel_deps="vdpau"
vc1_vdpau_hwaccel_select="vc1_decoder"
vp8_nvdec_hwaccel_deps="nvdec"
vp8_nvdec_hwaccel_select="vp8_decoder"
vp8_vaapi_hwaccel_deps="vaapi"
vp8_vaapi_hwaccel_select="vp8_decoder"
vp9_d3d11va_hwaccel_deps="d3d11va DXVA_PicParams_VP9"
vp9_d3d11va_hwaccel_select="vp9_decoder"
vp9_d3d11va2_hwaccel_deps="d3d11va DXVA_PicParams_VP9"
vp9_d3d11va2_hwaccel_select="vp9_decoder"
vp9_dxva2_hwaccel_deps="dxva2 DXVA_PicParams_VP9"
vp9_dxva2_hwaccel_select="vp9_decoder"
vp9_nvdec_hwaccel_deps="nvdec"
vp9_nvdec_hwaccel_select="vp9_decoder"
vp9_vaapi_hwaccel_deps="vaapi VADecPictureParameterBufferVP9_bit_depth"
vp9_vaapi_hwaccel_select="vp9_decoder"
wmv3_d3d11va_hwaccel_select="vc1_d3d11va_hwaccel"
wmv3_d3d11va2_hwaccel_select="vc1_d3d11va2_hwaccel"
wmv3_dxva2_hwaccel_select="vc1_dxva2_hwaccel"
wmv3_nvdec_hwaccel_select="vc1_nvdec_hwaccel"
wmv3_vaapi_hwaccel_select="vc1_vaapi_hwaccel"
wmv3_vdpau_hwaccel_select="vc1_vdpau_hwaccel"

# hardware-accelerated codecs
omx_deps="libdl pthreads"
omx_rpi_select="omx"
qsv_deps="libmfx"
qsvdec_select="qsv"
qsvenc_select="qsv"
qsvvpp_select="qsv"
vaapi_encode_deps="vaapi"
v4l2_m2m_deps="linux_videodev2_h sem_timedwait"

hwupload_cuda_filter_deps="ffnvcodec"
scale_npp_filter_deps="ffnvcodec libnpp"
scale_cuda_filter_deps="cuda_sdk"
thumbnail_cuda_filter_deps="cuda_sdk"
transpose_npp_filter_deps="ffnvcodec libnpp"

amf_deps_any="libdl LoadLibrary"
nvenc_deps="ffnvcodec"
nvenc_deps_any="libdl LoadLibrary"
nvenc_encoder_deps="nvenc"

h263_v4l2m2m_decoder_deps="v4l2_m2m h263_v4l2_m2m"
h263_v4l2m2m_encoder_deps="v4l2_m2m h263_v4l2_m2m"
h264_amf_encoder_deps="amf"
h264_crystalhd_decoder_select="crystalhd h264_mp4toannexb_bsf h264_parser"
h264_cuvid_decoder_deps="cuvid"
h264_cuvid_decoder_select="h264_mp4toannexb_bsf"
h264_mediacodec_decoder_deps="mediacodec"
h264_mediacodec_decoder_select="h264_mp4toannexb_bsf h264_parser"
h264_mmal_decoder_deps="mmal"
h264_nvenc_encoder_deps="nvenc"
h264_omx_encoder_deps="omx"
h264_qsv_decoder_select="h264_mp4toannexb_bsf h264_parser qsvdec"
h264_qsv_encoder_select="qsvenc"
h264_rkmpp_decoder_deps="rkmpp"
h264_rkmpp_decoder_select="h264_mp4toannexb_bsf"
h264_vaapi_encoder_select="cbs_h264 vaapi_encode"
h264_v4l2m2m_decoder_deps="v4l2_m2m h264_v4l2_m2m"
h264_v4l2m2m_encoder_deps="v4l2_m2m h264_v4l2_m2m"
hevc_amf_encoder_deps="amf"
hevc_cuvid_decoder_deps="cuvid"
hevc_cuvid_decoder_select="hevc_mp4toannexb_bsf"
hevc_mediacodec_decoder_deps="mediacodec"
hevc_mediacodec_decoder_select="hevc_mp4toannexb_bsf hevc_parser"
hevc_nvenc_encoder_deps="nvenc"
hevc_qsv_decoder_select="hevc_mp4toannexb_bsf hevc_parser qsvdec"
hevc_qsv_encoder_select="hevcparse qsvenc"
hevc_rkmpp_decoder_deps="rkmpp"
hevc_rkmpp_decoder_select="hevc_mp4toannexb_bsf"
hevc_vaapi_encoder_deps="VAEncPictureParameterBufferHEVC"
hevc_vaapi_encoder_select="cbs_h265 vaapi_encode"
hevc_v4l2m2m_decoder_deps="v4l2_m2m hevc_v4l2_m2m"
hevc_v4l2m2m_encoder_deps="v4l2_m2m hevc_v4l2_m2m"
mjpeg_cuvid_decoder_deps="cuvid"
mjpeg_qsv_encoder_deps="libmfx"
mjpeg_qsv_encoder_select="qsvenc"
mjpeg_vaapi_encoder_deps="VAEncPictureParameterBufferJPEG"
mjpeg_vaapi_encoder_select="cbs_jpeg jpegtables vaapi_encode"
mpeg1_cuvid_decoder_deps="cuvid"
mpeg1_v4l2m2m_decoder_deps="v4l2_m2m mpeg1_v4l2_m2m"
mpeg2_crystalhd_decoder_select="crystalhd"
mpeg2_cuvid_decoder_deps="cuvid"
mpeg2_mmal_decoder_deps="mmal"
mpeg2_mediacodec_decoder_deps="mediacodec"
mpeg2_qsv_decoder_select="qsvdec mpegvideo_parser"
mpeg2_qsv_encoder_select="qsvenc"
mpeg2_vaapi_encoder_select="cbs_mpeg2 vaapi_encode"
mpeg2_v4l2m2m_decoder_deps="v4l2_m2m mpeg2_v4l2_m2m"
mpeg4_crystalhd_decoder_select="crystalhd"
mpeg4_cuvid_decoder_deps="cuvid"
mpeg4_mediacodec_decoder_deps="mediacodec"
mpeg4_mmal_decoder_deps="mmal"
mpeg4_omx_encoder_deps="omx"
mpeg4_v4l2m2m_decoder_deps="v4l2_m2m mpeg4_v4l2_m2m"
mpeg4_v4l2m2m_encoder_deps="v4l2_m2m mpeg4_v4l2_m2m"
msmpeg4_crystalhd_decoder_select="crystalhd"
nvenc_h264_encoder_select="h264_nvenc_encoder"
nvenc_hevc_encoder_select="hevc_nvenc_encoder"
vc1_crystalhd_decoder_select="crystalhd"
vc1_cuvid_decoder_deps="cuvid"
vc1_mmal_decoder_deps="mmal"
vc1_qsv_decoder_select="qsvdec vc1_parser"
vc1_v4l2m2m_decoder_deps="v4l2_m2m vc1_v4l2_m2m"
vp8_cuvid_decoder_deps="cuvid"
vp8_mediacodec_decoder_deps="mediacodec"
vp8_qsv_decoder_select="qsvdec vp8_parser"
vp8_rkmpp_decoder_deps="rkmpp"
vp8_vaapi_encoder_deps="VAEncPictureParameterBufferVP8"
vp8_vaapi_encoder_select="vaapi_encode"
vp8_v4l2m2m_decoder_deps="v4l2_m2m vp8_v4l2_m2m"
vp8_v4l2m2m_encoder_deps="v4l2_m2m vp8_v4l2_m2m"
vp9_cuvid_decoder_deps="cuvid"
vp9_mediacodec_decoder_deps="mediacodec"
vp9_rkmpp_decoder_deps="rkmpp"
vp9_vaapi_encoder_deps="VAEncPictureParameterBufferVP9"
vp9_vaapi_encoder_select="vaapi_encode"
vp9_v4l2m2m_decoder_deps="v4l2_m2m vp9_v4l2_m2m"
wmv3_crystalhd_decoder_select="crystalhd"

# parsers
aac_parser_select="adts_header"
av1_parser_select="cbs_av1"
h264_parser_select="golomb h264dsp h264parse"
hevc_parser_select="hevcparse"
mpegaudio_parser_select="mpegaudioheader"
mpegvideo_parser_select="mpegvideo"
mpeg4video_parser_select="h263dsp mpegvideo qpeldsp"
vc1_parser_select="vc1dsp"

# bitstream_filters
aac_adtstoasc_bsf_select="adts_header"
av1_metadata_bsf_select="cbs_av1"
eac3_core_bsf_select="ac3_parser"
filter_units_bsf_select="cbs"
h264_metadata_bsf_deps="const_nan"
h264_metadata_bsf_select="cbs_h264"
h264_redundant_pps_bsf_select="cbs_h264"
hevc_metadata_bsf_select="cbs_h265"
mjpeg2jpeg_bsf_select="jpegtables"
mpeg2_metadata_bsf_select="cbs_mpeg2"
trace_headers_bsf_select="cbs"
vp9_metadata_bsf_select="cbs_vp9"

# external libraries
aac_at_decoder_deps="audiotoolbox"
aac_at_decoder_select="aac_adtstoasc_bsf"
ac3_at_decoder_deps="audiotoolbox"
ac3_at_decoder_select="ac3_parser"
adpcm_ima_qt_at_decoder_deps="audiotoolbox"
alac_at_decoder_deps="audiotoolbox"
amr_nb_at_decoder_deps="audiotoolbox"
avisynth_deps_any="libdl LoadLibrary"
avisynth_demuxer_deps="avisynth"
avisynth_demuxer_select="riffdec"
eac3_at_decoder_deps="audiotoolbox"
eac3_at_decoder_select="ac3_parser"
gsm_ms_at_decoder_deps="audiotoolbox"
ilbc_at_decoder_deps="audiotoolbox"
mp1_at_decoder_deps="audiotoolbox"
mp2_at_decoder_deps="audiotoolbox"
mp3_at_decoder_deps="audiotoolbox"
mp1_at_decoder_select="mpegaudioheader"
mp2_at_decoder_select="mpegaudioheader"
mp3_at_decoder_select="mpegaudioheader"
pcm_alaw_at_decoder_deps="audiotoolbox"
pcm_mulaw_at_decoder_deps="audiotoolbox"
qdmc_at_decoder_deps="audiotoolbox"
qdm2_at_decoder_deps="audiotoolbox"
aac_at_encoder_deps="audiotoolbox"
aac_at_encoder_select="audio_frame_queue"
alac_at_encoder_deps="audiotoolbox"
alac_at_encoder_select="audio_frame_queue"
ilbc_at_encoder_deps="audiotoolbox"
ilbc_at_encoder_select="audio_frame_queue"
pcm_alaw_at_encoder_deps="audiotoolbox"
pcm_alaw_at_encoder_select="audio_frame_queue"
pcm_mulaw_at_encoder_deps="audiotoolbox"
pcm_mulaw_at_encoder_select="audio_frame_queue"
chromaprint_muxer_deps="chromaprint"
h264_videotoolbox_encoder_deps="pthreads"
h264_videotoolbox_encoder_select="videotoolbox_encoder"
hevc_videotoolbox_encoder_deps="pthreads"
hevc_videotoolbox_encoder_select="videotoolbox_encoder"
libaom_av1_decoder_deps="libaom"
libaom_av1_encoder_deps="libaom"
libaom_av1_encoder_select="extract_extradata_bsf"
libcelt_decoder_deps="libcelt"
libcodec2_decoder_deps="libcodec2"
libcodec2_encoder_deps="libcodec2"
libdavs2_decoder_deps="libdavs2"
libfdk_aac_decoder_deps="libfdk_aac"
libfdk_aac_encoder_deps="libfdk_aac"
libfdk_aac_encoder_select="audio_frame_queue"
libgme_demuxer_deps="libgme"
libgsm_decoder_deps="libgsm"
libgsm_encoder_deps="libgsm"
libgsm_ms_decoder_deps="libgsm"
libgsm_ms_encoder_deps="libgsm"
libilbc_decoder_deps="libilbc"
libilbc_encoder_deps="libilbc"
libkvazaar_encoder_deps="libkvazaar"
libmodplug_demuxer_deps="libmodplug"
libmp3lame_encoder_deps="libmp3lame"
libmp3lame_encoder_select="audio_frame_queue mpegaudioheader"
libopencore_amrnb_decoder_deps="libopencore_amrnb"
libopencore_amrnb_encoder_deps="libopencore_amrnb"
libopencore_amrnb_encoder_select="audio_frame_queue"
libopencore_amrwb_decoder_deps="libopencore_amrwb"
libopenh264_decoder_deps="libopenh264"
libopenh264_decoder_select="h264_mp4toannexb_bsf"
libopenh264_encoder_deps="libopenh264"
libopenjpeg_decoder_deps="libopenjpeg"
libopenjpeg_encoder_deps="libopenjpeg"
libopenmpt_demuxer_deps="libopenmpt"
libopus_decoder_deps="libopus"
libopus_encoder_deps="libopus"
libopus_encoder_select="audio_frame_queue"
librsvg_decoder_deps="librsvg"
libshine_encoder_deps="libshine"
libshine_encoder_select="audio_frame_queue"
libspeex_decoder_deps="libspeex"
libspeex_encoder_deps="libspeex"
libspeex_encoder_select="audio_frame_queue"
libtheora_encoder_deps="libtheora"
libtwolame_encoder_deps="libtwolame"
libvo_amrwbenc_encoder_deps="libvo_amrwbenc"
libvorbis_decoder_deps="libvorbis"
libvorbis_encoder_deps="libvorbis libvorbisenc"
libvorbis_encoder_select="audio_frame_queue"
libvpx_vp8_decoder_deps="libvpx"
libvpx_vp8_encoder_deps="libvpx"
libvpx_vp9_decoder_deps="libvpx"
libvpx_vp9_encoder_deps="libvpx"
libwavpack_encoder_deps="libwavpack"
libwavpack_encoder_select="audio_frame_queue"
libwebp_encoder_deps="libwebp"
libwebp_anim_encoder_deps="libwebp"
libx262_encoder_deps="libx262"
libx264_encoder_deps="libx264"
libx264rgb_encoder_deps="libx264 x264_csp_bgr"
libx264rgb_encoder_select="libx264_encoder"
libx265_encoder_deps="libx265"
libxavs_encoder_deps="libxavs"
libxavs2_encoder_deps="libxavs2"
libxvid_encoder_deps="libxvid"
libzvbi_teletext_decoder_deps="libzvbi"
vapoursynth_demuxer_deps="vapoursynth"
videotoolbox_suggest="coreservices"
videotoolbox_deps="corefoundation coremedia corevideo"
videotoolbox_encoder_deps="videotoolbox VTCompressionSessionPrepareToEncodeFrames"

# demuxers / muxers
ac3_demuxer_select="ac3_parser"
aiff_muxer_select="iso_media"
asf_demuxer_select="riffdec"
asf_o_demuxer_select="riffdec"
asf_muxer_select="riffenc"
asf_stream_muxer_select="asf_muxer"
avi_demuxer_select="iso_media riffdec exif"
avi_muxer_select="riffenc"
caf_demuxer_select="iso_media riffdec"
caf_muxer_select="iso_media"
dash_muxer_select="mp4_muxer"
dash_demuxer_deps="libxml2"
dirac_demuxer_select="dirac_parser"
dts_demuxer_select="dca_parser"
dtshd_demuxer_select="dca_parser"
dv_demuxer_select="dvprofile"
dv_muxer_select="dvprofile"
dxa_demuxer_select="riffdec"
eac3_demuxer_select="ac3_parser"
f4v_muxer_select="mov_muxer"
fifo_muxer_deps="threads"
flac_demuxer_select="flac_parser"
hds_muxer_select="flv_muxer"
hls_muxer_select="mpegts_muxer"
hls_muxer_suggest="gcrypt openssl"
image2_alias_pix_demuxer_select="image2_demuxer"
image2_brender_pix_demuxer_select="image2_demuxer"
ipod_muxer_select="mov_muxer"
ismv_muxer_select="mov_muxer"
matroska_audio_muxer_select="matroska_muxer"
matroska_demuxer_select="iso_media riffdec"
matroska_demuxer_suggest="bzlib lzo zlib"
matroska_muxer_select="iso_media riffenc"
mmf_muxer_select="riffenc"
mov_demuxer_select="iso_media riffdec"
mov_demuxer_suggest="zlib"
mov_muxer_select="iso_media riffenc rtpenc_chain"
mp3_demuxer_select="mpegaudio_parser"
mp3_muxer_select="mpegaudioheader"
mp4_muxer_select="mov_muxer"
mpegts_demuxer_select="iso_media"
mpegts_muxer_select="adts_muxer latm_muxer"
mpegtsraw_demuxer_select="mpegts_demuxer"
mxf_d10_muxer_select="mxf_muxer"
mxf_opatom_muxer_select="mxf_muxer"
nut_muxer_select="riffenc"
nuv_demuxer_select="riffdec"
oga_muxer_select="ogg_muxer"
ogg_demuxer_select="dirac_parse"
ogv_muxer_select="ogg_muxer"
opus_muxer_select="ogg_muxer"
psp_muxer_select="mov_muxer"
rtp_demuxer_select="sdp_demuxer"
rtp_muxer_select="golomb"
rtpdec_select="asf_demuxer jpegtables mov_demuxer mpegts_demuxer rm_demuxer rtp_protocol srtp"
rtsp_demuxer_select="http_protocol rtpdec"
rtsp_muxer_select="rtp_muxer http_protocol rtp_protocol rtpenc_chain"
sap_demuxer_select="sdp_demuxer"
sap_muxer_select="rtp_muxer rtp_protocol rtpenc_chain"
sdp_demuxer_select="rtpdec"
smoothstreaming_muxer_select="ismv_muxer"
spdif_demuxer_select="adts_header"
spdif_muxer_select="adts_header"
spx_muxer_select="ogg_muxer"
swf_demuxer_suggest="zlib"
tak_demuxer_select="tak_parser"
tg2_muxer_select="mov_muxer"
tgp_muxer_select="mov_muxer"
vobsub_demuxer_select="mpegps_demuxer"
w64_demuxer_select="wav_demuxer"
w64_muxer_select="wav_muxer"
wav_demuxer_select="riffdec"
wav_muxer_select="riffenc"
webm_muxer_select="iso_media riffenc"
webm_dash_manifest_demuxer_select="matroska_demuxer"
wtv_demuxer_select="mpegts_demuxer riffdec"
wtv_muxer_select="mpegts_muxer riffenc"
xmv_demuxer_select="riffdec"
xwma_demuxer_select="riffdec"

# indevs / outdevs
android_camera_indev_deps="android camera2ndk mediandk pthreads"
android_camera_indev_extralibs="-landroid -lcamera2ndk -lmediandk"
alsa_indev_deps="alsa"
alsa_outdev_deps="alsa"
avfoundation_indev_deps="avfoundation corevideo coremedia pthreads"
avfoundation_indev_suggest="coregraphics applicationservices"
avfoundation_indev_extralibs="-framework Foundation"
bktr_indev_deps_any="dev_bktr_ioctl_bt848_h machine_ioctl_bt848_h dev_video_bktr_ioctl_bt848_h dev_ic_bt8xx_h"
caca_outdev_deps="libcaca"
decklink_deps_any="libdl LoadLibrary"
decklink_indev_deps="decklink threads"
decklink_indev_extralibs="-lstdc++"
decklink_outdev_deps="decklink threads"
decklink_outdev_suggest="libklvanc"
decklink_outdev_extralibs="-lstdc++"
libndi_newtek_indev_deps="libndi_newtek"
libndi_newtek_indev_extralibs="-lndi"
libndi_newtek_outdev_deps="libndi_newtek"
libndi_newtek_outdev_extralibs="-lndi"
dshow_indev_deps="IBaseFilter"
dshow_indev_extralibs="-lpsapi -lole32 -lstrmiids -luuid -loleaut32 -lshlwapi"
fbdev_indev_deps="linux_fb_h"
fbdev_outdev_deps="linux_fb_h"
gdigrab_indev_deps="CreateDIBSection"
gdigrab_indev_extralibs="-lgdi32"
gdigrab_indev_select="bmp_decoder"
iec61883_indev_deps="libiec61883"
jack_indev_deps="libjack"
jack_indev_deps_any="sem_timedwait dispatch_dispatch_h"
kmsgrab_indev_deps="libdrm"
lavfi_indev_deps="avfilter"
libcdio_indev_deps="libcdio"
libdc1394_indev_deps="libdc1394"
openal_indev_deps="openal"
opengl_outdev_deps="opengl"
oss_indev_deps_any="sys_soundcard_h"
oss_outdev_deps_any="sys_soundcard_h"
pulse_indev_deps="libpulse"
pulse_outdev_deps="libpulse"
sdl2_outdev_deps="sdl2"
sndio_indev_deps="sndio"
sndio_outdev_deps="sndio"
v4l2_indev_deps_any="linux_videodev2_h sys_videoio_h"
v4l2_indev_suggest="libv4l2"
v4l2_outdev_deps_any="linux_videodev2_h sys_videoio_h"
v4l2_outdev_suggest="libv4l2"
vfwcap_indev_deps="vfw32 vfwcap_defines"
xcbgrab_indev_deps="libxcb"
xcbgrab_indev_suggest="libxcb_shm libxcb_shape libxcb_xfixes"
xv_outdev_deps="xlib"

# protocols
async_protocol_deps="threads"
bluray_protocol_deps="libbluray"
ffrtmpcrypt_protocol_conflict="librtmp_protocol"
ffrtmpcrypt_protocol_deps_any="gcrypt gmp openssl mbedtls"
ffrtmpcrypt_protocol_select="tcp_protocol"
ffrtmphttp_protocol_conflict="librtmp_protocol"
ffrtmphttp_protocol_select="http_protocol"
ftp_protocol_select="tcp_protocol"
gopher_protocol_select="network"
http_protocol_select="tcp_protocol"
http_protocol_suggest="zlib"
httpproxy_protocol_select="tcp_protocol"
httpproxy_protocol_suggest="zlib"
https_protocol_select="tls_protocol"
https_protocol_suggest="zlib"
icecast_protocol_select="http_protocol"
mmsh_protocol_select="http_protocol"
mmst_protocol_select="network"
rtmp_protocol_conflict="librtmp_protocol"
rtmp_protocol_select="tcp_protocol"
rtmp_protocol_suggest="zlib"
rtmpe_protocol_select="ffrtmpcrypt_protocol"
rtmpe_protocol_suggest="zlib"
rtmps_protocol_conflict="librtmp_protocol"
rtmps_protocol_select="tls_protocol"
rtmps_protocol_suggest="zlib"
rtmpt_protocol_select="ffrtmphttp_protocol"
rtmpt_protocol_suggest="zlib"
rtmpte_protocol_select="ffrtmpcrypt_protocol ffrtmphttp_protocol"
rtmpte_protocol_suggest="zlib"
rtmpts_protocol_select="ffrtmphttp_protocol https_protocol"
rtmpts_protocol_suggest="zlib"
rtp_protocol_select="udp_protocol"
schannel_conflict="openssl gnutls libtls mbedtls"
sctp_protocol_deps="struct_sctp_event_subscribe struct_msghdr_msg_flags"
sctp_protocol_select="network"
securetransport_conflict="openssl gnutls libtls mbedtls"
srtp_protocol_select="rtp_protocol srtp"
tcp_protocol_select="network"
tls_protocol_deps_any="gnutls openssl schannel securetransport libtls mbedtls"
tls_protocol_select="tcp_protocol"
udp_protocol_select="network"
udplite_protocol_select="network"
unix_protocol_deps="sys_un_h"
unix_protocol_select="network"

# external library protocols
librtmp_protocol_deps="librtmp"
librtmpe_protocol_deps="librtmp"
librtmps_protocol_deps="librtmp"
librtmpt_protocol_deps="librtmp"
librtmpte_protocol_deps="librtmp"
libsmbclient_protocol_deps="libsmbclient gplv3"
libsrt_protocol_deps="libsrt"
libsrt_protocol_select="network"
libssh_protocol_deps="libssh"
libtls_conflict="openssl gnutls mbedtls"

# filters
afftdn_filter_deps="avcodec"
afftdn_filter_select="fft"
afftfilt_filter_deps="avcodec"
afftfilt_filter_select="fft"
afir_filter_deps="avcodec"
afir_filter_select="fft"
amovie_filter_deps="avcodec avformat"
aresample_filter_deps="swresample"
ass_filter_deps="libass"
atempo_filter_deps="avcodec"
atempo_filter_select="rdft"
avgblur_opencl_filter_deps="opencl"
azmq_filter_deps="libzmq"
blackframe_filter_deps="gpl"
bm3d_filter_deps="avcodec"
bm3d_filter_select="dct"
boxblur_filter_deps="gpl"
boxblur_opencl_filter_deps="opencl gpl"
bs2b_filter_deps="libbs2b"
colormatrix_filter_deps="gpl"
convolution_opencl_filter_deps="opencl"
convolve_filter_deps="avcodec"
convolve_filter_select="fft"
coreimage_filter_deps="coreimage appkit"
coreimage_filter_extralibs="-framework OpenGL"
coreimagesrc_filter_deps="coreimage appkit"
coreimagesrc_filter_extralibs="-framework OpenGL"
cover_rect_filter_deps="avcodec avformat gpl"
cropdetect_filter_deps="gpl"
deconvolve_filter_deps="avcodec"
deconvolve_filter_select="fft"
deinterlace_qsv_filter_deps="libmfx"
deinterlace_vaapi_filter_deps="vaapi"
delogo_filter_deps="gpl"
denoise_vaapi_filter_deps="vaapi"
deshake_filter_select="pixelutils"
dilation_opencl_filter_deps="opencl"
drawtext_filter_deps="libfreetype"
drawtext_filter_suggest="libfontconfig libfribidi"
elbg_filter_deps="avcodec"
eq_filter_deps="gpl"
erosion_opencl_filter_deps="opencl"
fftfilt_filter_deps="avcodec"
fftfilt_filter_select="rdft"
fftdnoiz_filter_deps="avcodec"
fftdnoiz_filter_select="fft"
find_rect_filter_deps="avcodec avformat gpl"
firequalizer_filter_deps="avcodec"
firequalizer_filter_select="rdft"
flite_filter_deps="libflite"
framerate_filter_select="pixelutils"
frei0r_filter_deps="frei0r libdl"
frei0r_src_filter_deps="frei0r libdl"
fspp_filter_deps="gpl"
geq_filter_deps="gpl"
histeq_filter_deps="gpl"
hqdn3d_filter_deps="gpl"
interlace_filter_deps="gpl"
kerndeint_filter_deps="gpl"
ladspa_filter_deps="ladspa libdl"
lensfun_filter_deps="liblensfun version3"
lv2_filter_deps="lv2"
mcdeint_filter_deps="avcodec gpl"
movie_filter_deps="avcodec avformat"
mpdecimate_filter_deps="gpl"
mpdecimate_filter_select="pixelutils"
mptestsrc_filter_deps="gpl"
negate_filter_deps="lut_filter"
nnedi_filter_deps="gpl"
ocr_filter_deps="libtesseract"
ocv_filter_deps="libopencv"
openclsrc_filter_deps="opencl"
overlay_opencl_filter_deps="opencl"
overlay_qsv_filter_deps="libmfx"
overlay_qsv_filter_select="qsvvpp"
owdenoise_filter_deps="gpl"
pan_filter_deps="swresample"
perspective_filter_deps="gpl"
phase_filter_deps="gpl"
pp7_filter_deps="gpl"
pp_filter_deps="gpl postproc"
prewitt_opencl_filter_deps="opencl"
procamp_vaapi_filter_deps="vaapi"
program_opencl_filter_deps="opencl"
pullup_filter_deps="gpl"
removelogo_filter_deps="avcodec avformat swscale"
repeatfields_filter_deps="gpl"
resample_filter_deps="avresample"
roberts_opencl_filter_deps="opencl"
rubberband_filter_deps="librubberband"
sab_filter_deps="gpl swscale"
scale2ref_filter_deps="swscale"
scale_filter_deps="swscale"
scale_qsv_filter_deps="libmfx"
select_filter_select="pixelutils"
sharpness_vaapi_filter_deps="vaapi"
showcqt_filter_deps="avcodec avformat swscale"
showcqt_filter_suggest="libfontconfig libfreetype"
showcqt_filter_select="fft"
showfreqs_filter_deps="avcodec"
showfreqs_filter_select="fft"
showspectrum_filter_deps="avcodec"
showspectrum_filter_select="fft"
showspectrumpic_filter_deps="avcodec"
showspectrumpic_filter_select="fft"
signature_filter_deps="gpl avcodec avformat"
smartblur_filter_deps="gpl swscale"
sobel_opencl_filter_deps="opencl"
sofalizer_filter_deps="libmysofa avcodec"
sofalizer_filter_select="fft"
spectrumsynth_filter_deps="avcodec"
spectrumsynth_filter_select="fft"
spp_filter_deps="gpl avcodec"
spp_filter_select="fft idctdsp fdctdsp me_cmp pixblockdsp"
sr_filter_deps="avformat swscale"
sr_filter_select="dnn"
stereo3d_filter_deps="gpl"
subtitles_filter_deps="avformat avcodec libass"
super2xsai_filter_deps="gpl"
pixfmts_super2xsai_test_deps="super2xsai_filter"
tinterlace_filter_deps="gpl"
tinterlace_merge_test_deps="tinterlace_filter"
tinterlace_pad_test_deps="tinterlace_filter"
tonemap_filter_deps="const_nan"
tonemap_opencl_filter_deps="opencl const_nan"
unsharp_opencl_filter_deps="opencl"
uspp_filter_deps="gpl avcodec"
vaguedenoiser_filter_deps="gpl"
vidstabdetect_filter_deps="libvidstab"
vidstabtransform_filter_deps="libvidstab"
libvmaf_filter_deps="libvmaf pthreads"
zmq_filter_deps="libzmq"
zoompan_filter_deps="swscale"
zscale_filter_deps="libzimg const_nan"
scale_vaapi_filter_deps="vaapi"
vpp_qsv_filter_deps="libmfx"
vpp_qsv_filter_select="qsvvpp"

# examples
avio_dir_cmd_deps="avformat avutil"
avio_reading_deps="avformat avcodec avutil"
decode_audio_example_deps="avcodec avutil"
decode_video_example_deps="avcodec avutil"
demuxing_decoding_example_deps="avcodec avformat avutil"
encode_audio_example_deps="avcodec avutil"
encode_video_example_deps="avcodec avutil"
extract_mvs_example_deps="avcodec avformat avutil"
filter_audio_example_deps="avfilter avutil"
filtering_audio_example_deps="avfilter avcodec avformat avutil"
filtering_video_example_deps="avfilter avcodec avformat avutil"
http_multiclient_example_deps="avformat avutil fork"
hw_decode_example_deps="avcodec avformat avutil"
metadata_example_deps="avformat avutil"
muxing_example_deps="avcodec avformat avutil swscale"
qsvdec_example_deps="avcodec avutil libmfx h264_qsv_decoder"
remuxing_example_deps="avcodec avformat avutil"
resampling_audio_example_deps="avutil swresample"
scaling_video_example_deps="avutil swscale"
transcode_aac_example_deps="avcodec avformat swresample"
transcoding_example_deps="avfilter avcodec avformat avutil"
vaapi_encode_example_deps="avcodec avutil h264_vaapi_encoder"
vaapi_transcode_example_deps="avcodec avformat avutil h264_vaapi_encoder"

# EXTRALIBS_LIST
cpu_init_extralibs="pthreads_extralibs"
cws2fws_extralibs="zlib_extralibs"

# libraries, in any order
avcodec_deps="avutil"
avcodec_suggest="libm"
avcodec_select="null_bsf"
avdevice_deps="avformat avcodec avutil"
avdevice_suggest="libm"
avfilter_deps="avutil"
avfilter_suggest="libm"
avformat_deps="avcodec avutil"
avformat_suggest="libm network zlib"
avresample_deps="avutil"
avresample_suggest="libm"
avutil_suggest="clock_gettime ffnvcodec libm libdrm libmfx opencl user32 vaapi videotoolbox corefoundation corevideo coremedia bcrypt"
postproc_deps="avutil gpl"
postproc_suggest="libm"
swresample_deps="avutil"
swresample_suggest="libm libsoxr"
swscale_deps="avutil"
swscale_suggest="libm"

avcodec_extralibs="pthreads_extralibs iconv_extralibs"
avfilter_extralibs="pthreads_extralibs"
avutil_extralibs="d3d11va_extralibs nanosleep_extralibs pthreads_extralibs vaapi_drm_extralibs vaapi_x11_extralibs vdpau_x11_extralibs"

# programs
ffmpeg_deps="avcodec avfilter avformat"
ffmpeg_select="aformat_filter anull_filter atrim_filter format_filter
               null_filter
               trim_filter"
ffmpeg_suggest="ole32 psapi shell32"
ffplay_deps="avcodec avformat swscale swresample sdl2"
ffplay_select="rdft crop_filter transpose_filter hflip_filter vflip_filter rotate_filter"
ffplay_suggest="shell32"
ffprobe_deps="avcodec avformat"
ffprobe_suggest="shell32"

# documentation
podpages_deps="perl"
manpages_deps="perl pod2man"
htmlpages_deps="perl"
htmlpages_deps_any="makeinfo_html texi2html"
txtpages_deps="perl makeinfo"
doc_deps_any="manpages htmlpages podpages txtpages"

# default parameters

logfile="ffbuild/config.log"

# installation paths
prefix_default="/usr/local"
bindir_default='${prefix}/bin'
datadir_default='${prefix}/share/ffmpeg'
docdir_default='${prefix}/share/doc/ffmpeg'
incdir_default='${prefix}/include'
libdir_default='${prefix}/lib'
mandir_default='${prefix}/share/man'

# toolchain
ar_default="ar"
cc_default="gcc"
cxx_default="g++"
host_cc_default="gcc"
doxygen_default="doxygen"
install="install"
ln_s_default="ln -s -f"
nm_default="nm -g"
pkg_config_default=pkg-config
ranlib_default="ranlib"
strip_default="strip"
version_script='--version-script'
objformat="elf32"
x86asmexe_default="nasm"
windres_default="windres"
nvcc_default="nvcc"
nvccflags_default="-gencode arch=compute_30,code=sm_30 -O2"
striptype="direct"

log() {
	echo "$@" >>$logfile
}

log_file() {
	log BEGIN $1
	pr -n -t $1 >>$logfile
	log END $1
}

warn() {
	log "WARNING: $*"
	WARNINGS="${WARNINGS}WARNING: $*\n"
}

die() {
	log "$@"
	echo "$error_color$bold_color$@$reset_color"
	cat <<EOF

If you think configure made a mistake, make sure you are using the latest
version from Git.  If the latest version fails, report the problem to the
ffmpeg-user@ffmpeg.org mailing list or IRC #ffmpeg on irc.freenode.net.
EOF
	if disabled logging; then
		cat <<EOF
Rerun configure with logging enabled (do not use --disable-logging), and
include the log this produces with your report.
EOF
	else
		cat <<EOF
Include the log file "$logfile" produced by configure as this will help
solve the problem.
EOF
	fi
	exit 1
}

# Avoid locale weirdness, besides we really just want to translate ASCII.
toupper() {
	echo "$@" | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}

tolower() {
	echo "$@" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}

c_escape() {
	echo "$*" | sed 's/["\\]/\\\0/g'
}

sh_quote() {
	v=$(echo "$1" | sed "s/'/'\\\\''/g")
	test "x$v" = "x${v#*[!A-Za-z0-9_/.+-]}" || v="'$v'"
	echo "$v"
}

cleanws() {
	echo "$@" | sed 's/^ *//;s/[[:space:]][[:space:]]*/ /g;s/ *$//'
}

filter() {
	pat=$1
	shift
	for v; do
		eval "case '$v' in $pat) printf '%s ' '$v' ;; esac"
	done
}

filter_out() {
	pat=$1
	shift
	for v; do
		eval "case '$v' in $pat) ;; *) printf '%s ' '$v' ;; esac"
	done
}

map() {
	m=$1
	shift
	for v; do eval $m; done
}

add_suffix() {
	suffix=$1
	shift
	for v; do echo ${v}${suffix}; done
}

remove_suffix() {
	suffix=$1
	shift
	for v; do echo ${v%$suffix}; done
}

set_all() {
	value=$1
	shift
	for var in $*; do
		eval $var=$value
	done
}

set_weak() {
	value=$1
	shift
	for var; do
		eval : \${$var:=$value}
	done
}

sanitize_var_name() {
	echo $@ | sed 's/[^A-Za-z0-9_]/_/g'
}

set_sanitized() {
	var=$1
	shift
	eval $(sanitize_var_name "$var")='$*'
}

get_sanitized() {
	eval echo \$$(sanitize_var_name "$1")
}

pushvar() {
	for pvar in $*; do
		eval level=\${${pvar}_level:=0}
		eval ${pvar}_${level}="\$$pvar"
		eval ${pvar}_level=$(($level + 1))
	done
}

popvar() {
	for pvar in $*; do
		eval level=\${${pvar}_level:-0}
		test $level = 0 && continue
		eval level=$(($level - 1))
		eval $pvar="\${${pvar}_${level}}"
		eval ${pvar}_level=$level
		eval unset ${pvar}_${level}
	done
}

request() {
	for var in $*; do
		eval ${var}_requested=yes
		eval $var=
	done
}

enable() {
	set_all yes $*
}

disable() {
	set_all no $*
}

enable_weak() {
	set_weak yes $*
}

disable_weak() {
	set_weak no $*
}

enable_sanitized() {
	for var; do
		enable $(sanitize_var_name $var)
	done
}

disable_sanitized() {
	for var; do
		disable $(sanitize_var_name $var)
	done
}

do_enable_deep() {
	for var; do
		enabled $var && continue
		set -- $var
		eval enable_deep \$${var}_select
		var=$1
		eval enable_deep_weak \$${var}_suggest
	done
}

enable_deep() {
	do_enable_deep $*
	enable $*
}

enable_deep_weak() {
	for var; do
		disabled $var && continue
		set -- $var
		do_enable_deep $var
		var=$1
		enable_weak $var
	done
}

requested() {
	test "${1#!}" = "$1" && op="=" || op="!="
	eval test "x\$${1#!}_requested" $op "xyes"
}

enabled() {
	test "${1#!}" = "$1" && op="=" || op="!="
	eval test "x\$${1#!}" $op "xyes"
}

disabled() {
	test "${1#!}" = "$1" && op="=" || op="!="
	eval test "x\$${1#!}" $op "xno"
}

enabled_all() {
	for opt; do
		enabled $opt || return 1
	done
}

disabled_all() {
	for opt; do
		disabled $opt || return 1
	done
}

enabled_any() {
	for opt; do
		enabled $opt && return 0
	done
}

disabled_any() {
	for opt; do
		disabled $opt && return 0
	done
	return 1
}

set_default() {
	for opt; do
		eval : \${$opt:=\$${opt}_default}
	done
}

is_in() {
	value=$1
	shift
	for var in $*; do
		[ $var = $value ] && return 0
	done
	return 1
}

check_deps() {
	for cfg; do
		eval [ x\$${cfg}_checking = xdone ] && continue
		eval [ x\$${cfg}_checking = xinprogress ] && die "Circular dependency for $cfg."

		eval "
        dep_all=\$${cfg}_deps
        dep_any=\$${cfg}_deps_any
        dep_con=\$${cfg}_conflict
        dep_sel=\$${cfg}_select
        dep_sgs=\$${cfg}_suggest
        dep_ifa=\$${cfg}_if
        dep_ifn=\$${cfg}_if_any
        "

		if test "$cfg" = 'sysctl'; then
			echo ${cfg} dep_all:${dep_all} dep_any:${dep_any} dep_con:${dep_con} dep_sel:${dep_sel} dep_sgs:${dep_sgs} dep_ifa:${dep_ifa} dep_ifn:${dep_ifn} library:$LIBRARY_LIST
			exit 1
		fi

		echo $cfg:"dep_all:$dep_all dep_any:$dep_any dep_con:$dep_con dep_sel:$dep_sel dep_sgs:$dep_sgs dep_ifa:$dep_ifa dep_ifn:$dep_ifn"
		# most of the time here $cfg has no deps - avoid costly no-op work
		if [ "$dep_all$dep_any$dep_con$dep_sel$dep_sgs$dep_ifa$dep_ifn" ]; then
			eval ${cfg}_checking=inprogress

			set -- $cfg "$dep_all" "$dep_any" "$dep_con" "$dep_sel" "$dep_sgs" "$dep_ifa" "$dep_ifn"
			check_deps $dep_all $dep_any $dep_con $dep_sel $dep_sgs $dep_ifa $dep_ifn
			cfg=$1
			dep_all=$2
			dep_any=$3
			dep_con=$4
			dep_sel=$5 dep_sgs=$6
			dep_ifa=$7
			dep_ifn=$8

			[ -n "$dep_ifa" ] && { enabled_all $dep_ifa && enable_weak $cfg; }
			[ -n "$dep_ifn" ] && { enabled_any $dep_ifn && enable_weak $cfg; }
			enabled_all $dep_all || { disable $cfg && requested $cfg && die "ERROR: $cfg requested, but not all dependencies are satisfied: $dep_all"; }
			enabled_any $dep_any || { disable $cfg && requested $cfg && die "ERROR: $cfg requested, but not any dependency is satisfied: $dep_any"; }
			disabled_all $dep_con || { disable $cfg && requested $cfg && die "ERROR: $cfg requested, but some conflicting dependencies are unsatisfied: $dep_con"; }
			disabled_any $dep_sel && { disable $cfg && requested $cfg && die "ERROR: $cfg requested, but some selected dependency is unsatisfied: $dep_sel"; }

			enabled $cfg && enable_deep_weak $dep_sel $dep_sgs

			for dep in $dep_all $dep_any $dep_sel $dep_sgs; do
				# filter out library deps, these do not belong in extralibs
				is_in $dep $LIBRARY_LIST && continue
				enabled $dep && eval append ${cfg}_extralibs ${dep}_extralibs
			done
		fi

		eval ${cfg}_checking=done
	done
}

check_deps $ARCH_EXT_LIST_ARM

enabled() {
	test "${1#!}" = "$1" && op="=" || op="!="
	eval test "x\$${1#!}" $op "xyes"
}

enabled !getenv
