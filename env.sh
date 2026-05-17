#!/system/bin/sh

# Copyright (c) 2026 rebangkkuser.
# All rights reserved
#
# This project is licensed under the GNU General Public License (GPL), version 3

# RootFS structutre
if [ "$(id -u)" -ne 0 ]; then
    exec su -c "$0" "$@"
fi
clear
DIR=/data/local/androcli
GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"
cat <<EOF
${GREEN}
                 _           _     _            _ _
  __ _ _ __   __| |_ __ ___ (_) __| |       ___| (_)
 / _` | '_ \ / _` | '__/ _ \| |/ _` |_____ / __| | |
| (_| | | | | (_| | | | (_) | | (_| |_____| (__| | |
 \__,_|_| |_|\__,_|_|  \___/|_|\__,_|      \___|_|_|

${RESET}
EOF
 echo "Installer v0.1 alpha 2"
 echo "see fixes on
 echo -e "${BLUE}[*]${RESET} Starting install..."
mkdir -p $DIR
mkdir -p $DIR/system
mkdir -p $DIR/vendor
ln -sf ./vendor $DIR/system/vendor
mkdir -p $DIR/system/lib64
mkdir -p $DIR/vendor/lib64
mkdir -p $DIR/system/bin
ln -sf ./system/bin $DIR/bin
mkdir -p $DIR/vendor/bin
mkdir -p $DIR/system/xbin
ln -sf ./system/xbin $DIR/xbin
mkdir -p $DIR/linkerconfig
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
# Installing toybox (es)
cd $DIR/system/bin || exit 1
for cmd in $($DIR/system/bin/toybox); do ln -sf "$DIR/system/bin/toybox" "$cmd"; done
cd $DIR/vendor/bin || exit 1
for cmd in $($DIR/vendor/bin/toybox_vendor); do ln -sf "$DIR/vendor/bin/toybox_vendor" "$cmd"; done
cd - > /dev/null
# Making bind mounts
mount --bind /dev $DIR/dev
mount --bind /proc $DIR/proc
mount --bind /sys $DIR/sys
# Copying Bionic for /system/bin/sh and /vendor/bin/sh (works only with APEX devices)
cp /apex/com.android.runtime/lib64/bionic/libc.so $DIR/system/lib64/libc.so
cp /apex/com.android.runtime/lib64/bionic/libdl.so $DIR/system/lib64/libdl.so
cp /apex/com.android.runtime/lib64/bionic/libm.so $DIR/system/lib64/libm.so
# Copying shells
cp /system/bin/sh $DIR/system/bin/sh
cp /vendor/bin/sh $DIR/vendor/bin/sh
# Copying libs and linkerconfig
cp /system/lib64/libc++.so $DIR/system/lib64/libc++.so
cp /system/lib64/libz.so $DIR/system/lib64/libz.so
cp /system/lib64/libselinux.so $DIR/system/lib64/libselinux.so
cp /system/lib64/libpackagelistparser.so $DIR/system/lib64/libpackagelistparser.so
cp /system/lib64/libpcre2.so $DIR/system/lib64/libpcre2.so
cp /system/lib64/liblog.so $DIR/system/lib64/liblog.so
cp /system/lib64/libcrypto.so $DIR/system/lib64/libcrypto.so
cp /vendor/lib64/libc++.so $DIR/vendor/lib64/libc++.so
cp /vendor/lib64/libz.so $DIR/vendor/lib64/libz.so
cp /vendor/lib64/libselinux.so $DIR/vendor/lib64/libselinux.so
cp /vendor/lib64/libpackagelistparser.so $DIR/vendor/lib64/libpackagelistparser.so
cp /vendor/lib64/libpcre2.so $DIR/vendor/lib64/libpcre2.so
cp /vendor/lib64/liblog.so $DIR/vendor/lib64/liblog.so
cp /vendor/lib64/libcrypto.so $DIR/vendor/lib64/libcrypto.so
cp /linkerconfig/ld.config.txt $DIR/linkerconfig/ld.config.txt
# Extra binaries
cp "$(command -v ldd)" $DIR/system/xbin/ldd
# Build properties
echo "# begin build properties
# made by bangkkuser

ro.product.model=generic_cli
ro.product.build.fingerprint=generic_cli/generic/cligen/CUMN.261605.000/m4a7p:eng/test-keys
ro.cli.home=/root
ro.build.version.sdk=3
ro.build.version.release=1.5-acli
ro.build.id=CUMN.261605.000
ro.build.type=eng
ro.build.tags=test-keys
ro.github=rebangkkuser/androcli" > $DIR/system/build.prop

echo "# begin vendor build properties
# made by bangkkuser

ro.vendor.product.model=generic_cli
ro.vendor.product.build.fingerprint=generic_cli/generic/cligen/CUMN.261605.000/m4a7p:eng/test-keys
ro.vendor.cli.home=/root
ro.vendor.build.version.sdk=3
ro.vendor.build.version.release=1.5-acli
ro.vendor.build.id=CUMN.261605.000
ro.vendor.build.type=eng
ro.vendor.build.tags=test-keys
ro.vendor.github=rebangkkuser/androcli" > $DIR/vendor/build.prop

echo "ro.secure=0
ro.debuggable=1
persist.sys.usb.config=adb" > $DIR/default.prop

echo -e "${GREEN}[*]${RESET} Finished at ${BLUE}[$(date +%H:%M:%S)]${RESET}, on $(date +%d%m)"
