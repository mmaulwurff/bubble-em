#!/bin/bash

set -e

filename=bubble-em-$(git describe --abbrev=0 --tags).pk3

rm -f  $filename
zip -R $filename "*.md" "*.txt" "*.zs" "*.png" "*.ogg"
gzdoom $filename "$@"
