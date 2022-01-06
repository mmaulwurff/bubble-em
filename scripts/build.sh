#!/bin/bash

mkdir -p build

filename=build/bubble-em-$(git describe --abbrev=0 --tags).pk3

rm -f  "$filename"
zip -R "$filename" "*.md" "*.txt" "*.zs" "*.png" "*.ogg"
gzdoom "$filename" "$@" > output 2>&1; cat output
