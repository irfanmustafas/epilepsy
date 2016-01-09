#!/bin/sh

#files=($(find $1 -type f -name "*.mp4"))

for f in `find $1 -type f -name "*.mp4"`; do
    echo "Converting to theora..."
    ogv="${f%.mp4}.ogv"
    echo "$f -> $ogv"
    ffmpeg -i "$f" -acodec libvorbis -vcodec libtheora -q:v 10 "$ogv"
done
