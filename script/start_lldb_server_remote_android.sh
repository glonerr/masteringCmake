echo "************************************************************************"
echo "****************** start_lldb_server_remote_android ********************"
echo "************************************************************************"

adb shell "mkdir -p /data/local/tmp/debug"
adb push /home/lonerr/Tools/worktools/android/android-sdk/lldb/3.1/android/arm64-v8a/lldb-server /data/local/tmp/debug/
adb shell "chmod a+x /data/local/tmp/debug/lldb-server"
adb shell "pkill lldb-server"
adb shell "cd /data/local/tmp/debug/ && ./lldb-server platform --server --listen unix-abstract:///data/local/tmp/debug.sock"