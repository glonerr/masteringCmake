#!/bin/bash
cd build && rm -rf * && cmake ../ && make -j
adb push libavutil/libavutil.so /data/local/tmp
for i in $(ls libavutil/tests); do
	adb push libavutil/tests/$i /data/local/tmp
	echo "******************************************************************"
	echo "*********************** test $i *************************"
	adb shell export "LD_LIBRARY_PATH=/data/local/tmp&&/data/local/tmp/$i"
	echo "******************************************************************"
done
# file libavutil/main && adb push libavutil/libavutil.so libavutil/main /data/local/tmp && adb shell export "LD_LIBRARY_PATH=/data/local/tmp&&/data/local/tmp/main"
