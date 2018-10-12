set_default(){
    for opt; do
        eval : \${$opt:=\$${opt}_default}
    done
}

arch=aarch64
arch_default=x86_64
cc_default=gcc
cc=clang

set_default arch

echo "arch:$arch"
echo "cc:$cc"

pushvar(){
    for pvar in $*; do
        eval level=\${${pvar}_level:=0}
        eval ${pvar}_${level}="\$$pvar"
        eval ${pvar}_level=$(($level+1))
    done
}

popvar(){
    for pvar in $*; do
        eval level=\${${pvar}_level:-0}
        test $level = 0 && continue
        eval level=$(($level-1))
        eval $pvar="\${${pvar}_${level}}"
        eval ${pvar}_level=$level
        eval unset ${pvar}_${level}
    done
}

enable(){
    set_all yes $*
}

disable(){
    set_all no $*
}

set_all(){
    value=$1
    shift
    for var in $*; do
        eval $var=$value
    done
}

enabled(){
    test "${1#!}" = "$1" && op="=" || op="!="
    eval test "x\$${1#!}" $op "xyes"
}

disabled(){
    test "${1#!}" = "$1" && op="=" || op="!="
    eval test "x\$${1#!}" $op "xno"
}

enabled_all(){
    for opt; do
        enabled $opt || return 1
    done
}

disabled_all(){
    for opt; do
        disabled $opt || return 1
    done
}

enabled_any(){
    for opt; do
        enabled $opt && return 0
    done
}

disabled_any(){
    for opt; do
        disabled $opt && return 0
    done
    return 1
}

check_deps(){
    for cfg; do
        enabled ${cfg}_checking && die "Circular dependency for $cfg."
        disabled ${cfg}_checking && continue
        enable ${cfg}_checking

        eval dep_all="\$${cfg}_deps"
        eval dep_any="\$${cfg}_deps_any"
        eval dep_con="\$${cfg}_conflict"
        eval dep_sel="\$${cfg}_select"
        eval dep_sgs="\$${cfg}_suggest"
        eval dep_ifa="\$${cfg}_if"
        eval dep_ifn="\$${cfg}_if_any"

        pushvar cfg dep_all dep_any dep_con dep_sel dep_sgs dep_ifa dep_ifn
        check_deps $dep_all $dep_any $dep_con $dep_sel $dep_sgs $dep_ifa $dep_ifn
        popvar cfg dep_all dep_any dep_con dep_sel dep_sgs dep_ifa dep_ifn

        [ -n "$dep_ifa" ] && { enabled_all $dep_ifa && enable_weak $cfg; }
        [ -n "$dep_ifn" ] && { enabled_any $dep_ifn && enable_weak $cfg; }
        enabled_all  $dep_all || { disable $cfg && requested $cfg && die "ERROR: $cfg requested, but not all dependencies are satisfied: $dep_all"; }
        enabled_any  $dep_any || { disable $cfg && requested $cfg && die "ERROR: $cfg requested, but not any dependency is satisfied: $dep_any"; }
        disabled_all $dep_con || { disable $cfg && requested $cfg && die "ERROR: $cfg requested, but some conflicting dependencies are unsatisfied: $dep_con"; }
        disabled_any $dep_sel && { disable $cfg && requested $cfg && die "ERROR: $cfg requested, but some selected dependency is unsatisfied: $dep_sel"; }

        enabled $cfg && enable_deep_weak $dep_sel $dep_sgs

        for dep in $dep_all $dep_any $dep_sel $dep_sgs; do
            # filter out library deps, these do not belong in extralibs
            is_in $dep $LIBRARY_LIST && continue
            enabled $dep && eval append ${cfg}_extralibs ${dep}_extralibs
        done

        disable ${cfg}_checking
    done
}

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

check_deps $SYSTEM_FUNCS