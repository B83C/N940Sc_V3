#!/bin/sh

if [ ! -d ./ramdisk ]; then
    echo "Please, you have forgotten to add the root folder (ramdisk)..."
    exit 1
fi

cd ./ramdisk

find . ! -name . | LC_ALL=C sort | cpio -o -H newc -R root:root | gzip > ../ramdisk.gz

cd ..
