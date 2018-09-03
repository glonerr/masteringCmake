echo "************************************************************************"
echo "****************** start_lldb_server_remote_android ********************"
echo "************************************************************************"

echo "mkdir"
adb shell "mkdir -p /data/local/tmp/lldb/bin"
adb shell "mkdir -p /data/local/tmp/lldb/tmp"
adb shell "mkdir -p /data/local/tmp/lldb/log"
echo "push lldb-server"
adb push /home/lonerr/Tools/worktools/android/android-sdk/lldb/3.1/android/arm64-v8a/lldb-server /data/local/tmp/lldb/bin/
adb push /home/lonerr/Tools/worktools/android/android-sdk/lldb/3.1/android/start_lldb_server.sh /data/local/tmp/lldb/bin/
adb shell "chmod a+x /data/local/tmp/lldb/bin/lldb-server"
adb shell "chmod a+x /data/local/tmp/lldb/bin/start_lldb_server.sh"
echo "kill ps"
adb shell "pkill lldb-server"
echo "start lldb-server"
adb shell "sh ./data/local/tmp/lldb/bin/start_lldb_server.sh /data/local/tmp/lldb unix-abstract /data/local/tmp/lldb/tmp debug.sock"
adb shell "export LD_LIBRARY_PATH=/data/local/tmp/lldb/tmp"