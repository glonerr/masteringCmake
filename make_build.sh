#!/bin/bash
cd build && rm -rf * && cmake ../ && make -j
adb push libavutil/libavutil.so /data/local/tmp
for i in adler32 aes aes_ctr audio_fifo avstring base64 blowfish bprint cast5 camellia color_utils cpu crc des dict display encryption_info error eval file fifo hash hmac hwdevice integer imgutils lfg lls log md5 murmur3 opt pca parseutils pixdesc pixelutils pixfmt_best random_seed rational ripemd sha sha512 softfloat tree twofish utf8 xtea tea; do
	adb push libavutil/tests/$i /data/local/tmp
	echo "******************************************************************"
	echo "*********************** test $i *************************"
	adb shell export "LD_LIBRARY_PATH=/data/local/tmp&&/data/local/tmp/$i"
	echo "******************************************************************"
done
