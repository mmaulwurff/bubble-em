#!/bin/bash

set -e

#filename=10.5x-$(git describe --abbrev=0 --tags).pk3
filename=bubble-em.pk3

rm -f  $filename
zip -R $filename "*.md" "*.txt" "*.zs" "*.png" "*.ogg"
gzdoom $filename "$@"
