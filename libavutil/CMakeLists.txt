project(avutil)

set(src adler32.c aes.c aes_ctr.c audio_fifo.c avstring.c base64.c blowfish.c bprint.c buffer.c cast5.c camellia.c channel_layout.c color_utils.c cpu.c crc.c des.c dict.c display.c downmix_info.c encryption_info.c error.c eval.c fifo.c file.c file_open.c float_dsp.c fixed_dsp.c frame.c hash.c hmac.c hwcontext.c imgutils.c integer.c intmath.c lfg.c lls.c log.c log2_tab.c mathematics.c mastering_display_metadata.c md5.c mem.c murmur3.c opt.c parseutils.c pixdesc.c pixelutils.c random_seed.c rational.c reverse.c rc4.c ripemd.c samplefmt.c sha.c sha512.c slicethread.c spherical.c stereo3d.c threadmessage.c time.c timecode.c tree.c twofish.c utils.c xga_font_data.c xtea.c tea.c)

include_directories(../)

add_subdirectory(${ARCH})

add_library(avutil SHARED $<TARGET_OBJECTS:avutil_${ARCH}> ${src})

if(TEST_AVUTIL)
    add_subdirectory(tests)
endif()