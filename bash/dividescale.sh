#!/bin/sh
[ -d $1 ] && exit
[ -z $2 ] && $2=4

n=$2

res=`ffmpeg -i $1 2>&1 | grep Stream | grep -oP ', \K[0-9]+x[0-9]+'`
IFS='x' read -ra resArr <<< "$res"

w="${resArr[0]}"
h="${resArr[1]}"
echo "w=$w h=$h"

for i in $(seq 1 $n); do
    w=$(($w / 2));
    h=$(($h/ 2));
    filename="${w}x${h}.ogv"
    echo "Converting to ${w}x${h}, output to $filename"
    ffmpeg -i $1 -vf scale=$w:$h -q:v 10 $filename &> /dev/null
done
