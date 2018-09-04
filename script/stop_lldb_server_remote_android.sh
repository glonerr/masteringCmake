echo "************************************************************************"
echo "******************* stop_lldb_server_remote_android ********************"
echo "************************************************************************"

echo "kill ps"
adb shell "pkill lldb-server"
echo "clean env"
adb shell "rm -rf /data/local/tmp/lldb/"