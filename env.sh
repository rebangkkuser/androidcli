#!/system/bin/sh

# Copyright (c) 2026 rebangkkuser.
# All rights reserved
#
# This project is licensed under the GNU General Public License (GPL), version 3

# RootFS structure
DIR=/data/local/androcli
su
mkdir -p $DIR
mkdir -p $DIR/system
mkdir -p $DIR/vendor
ln -sf $DIR/vendor $DIR/system/vendor
mkdir -p $DIR/system/lib64
mkdir -p $DIR/system/bin
ln -sf $DIR/system/bin $DIR/bin
mkdir -p $DIR/vendor/bin
mkdir -p $DIR/system/xbin
ln -sf $DIR/system/xbin $DIR/xbin
mkdir -p $DIR/vendor/xbin
mkdir -p $DIR/dev
mkdir -p $DIR/proc
mkdir -p $DIR/sys

# Cloning system toybox and linkers
cp /system/bin/toybox $DIR/system/bin/toybox
cp /system/bin/linker64 $DIR/system/bin/linker64
cp /system/bin/linker $DIR/system/bin/linker

# Cloning vendor toybox
cp /vendor/bin/toybox_vendor $DIR/vendor/bin/toybox_vendor

# Installing toybox (es) - FIXED:entering folder and cloning locally
cd $DIR/system/bin
for cmd in $(./toybox); do ln -sf "./toybox" "$cmd"; done

cd $DIR/vendor/bin
for cmd in $(./toybox_vendor); do ln -sf "./toybox_vendor" "$cmd"; done

# Back to script root
cd - > /dev/null

# Making bind mounts
mount --bind /dev $DIR/dev
mount --bind /proc $DIR/proc
mount --bind /sys $DIR/sys

# Copying libc.so and libdl.so for /system/bin/sh and /vendor/bin/sh (works only with APEX devices)
cp /apex/com.android.runtime/lib64/bionic/libc.so $DIR/system/lib64/libc.so
cp /apex/com.android.runtime/lib64/bionic/libdl.so $DIR/system/lib64/libdl.so

# Copying shells
cp /system/bin/sh $DIR/system/bin/sh
cp /vendor/bin/sh $DIR/vendor/bin/sh

# Extra binaries
cp $(command -v ldd) $DIR/system/xbin/ldd
