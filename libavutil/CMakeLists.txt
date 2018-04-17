###############################################################################
# x86[-64] (NASM)
###############################################################################
message(STATUS ${CPU_TYPE})

# if(CPU_TYPE STREQUAL "x86_64" OR CPU_TYPE STREQUAL "i386")

#     set(CMAKE_ASM_NASM_FLAGS_DEBUG_INIT "-g")
#     set(CMAKE_ASM_NASM_FLAGS_RELWITHDEBINFO_INIT "-g")

#     # Allow the location of the NASM executable to be specified using the ASM_NASM
#     # environment variable.  This should happen automatically, but unfortunately
#     # enable_language(ASM_NASM) doesn't parse the ASM_NASM environment variable
#     # until after CMAKE_ASM_NASM_COMPILER has been populated with the results of
#     # searching for NASM or YASM in the PATH.
#     if(NOT DEFINED CMAKE_ASM_NASM_COMPILER AND DEFINED ENV{ASM_NASM})
#     set(CMAKE_ASM_NASM_COMPILER $ENV{ASM_NASM})
#     endif()

#     if(CPU_TYPE STREQUAL "x86_64")
#     if(CYGWIN)
#         set(CMAKE_ASM_NASM_OBJECT_FORMAT win64)
#     endif()
#     elseif(CPU_TYPE STREQUAL "i386")
#     if(BORLAND)
#         set(CMAKE_ASM_NASM_OBJECT_FORMAT obj)
#     elseif(CYGWIN)
#         set(CMAKE_ASM_NASM_OBJECT_FORMAT win32)
#     endif()
#     endif()
# endif() # CPU_TYPE
# include_directories(../)
# aux_source_directory(. AVUTIL_SRC)
# aux_source_directory(./${ARCH} AVUTIL_SRC)
# enable_language(ASM_NASM)
# add_definitions(-DHAVE_AV_CONFIG_H)
# add_library(avutil SHARED ${AVUTIL_SRC} ./${ARCH}/cpuid.asm)
# target_link_libraries(avutil pthread)