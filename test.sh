#/usr/bin/bash
myfile="asdf"
# echo $myfile
eval : \${myfile=$1}
echo $myfile