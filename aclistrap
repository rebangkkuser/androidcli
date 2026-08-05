
#!/system/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
    exec su -c "$0" "$@"
fi

DIR="/data/local/androcli"

GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"

clear

printf "${GREEN}"

if command -v figlet >/dev/null 2>&1; then
    figlet androidcli
else
cat <<'EOF'
       _           _     _      _ _
  __ _ _ __   __| |_ __ ___ (_) __| | ___| (_)
 / _` | '_ \ / _` | '__/ _ \| |/ _` |/ __| | |
| (_| | | | | (_| | | | (_) | | (_| | (__| | |
 \__,_|_| |_|\__,_|_|  \___|_|\__,_|\___|_|_|
EOF
fi

printf "${RESET}"

echo "AndroidCLI Installer"

SDK="$(getprop ro.build.version.sdk)"

if [ "$SDK" -lt 29 ]; then
    echo "[-] Android 10+ required"
    exit 1
fi

if [ ! -d "/apex/com.android.runtime" ]; then
    echo "[-] APEX runtime missing"
    exit 1
fi


echo -e "${BLUE}[*]${RESET} Creating filesystem"

mkdir -p \
"$DIR/apex" \
"$DIR/system/bin" \
"$DIR/system/lib64" \
"$DIR/system/xbin" \
"$DIR/vendor/bin" \
"$DIR/vendor/lib64" \
"$DIR/vendor/xbin" \
"$DIR/linkerconfig" \
"$DIR/root" \
"$DIR/dev" \
"$DIR/proc" \
"$DIR/sys"


ln -sfn "$DIR/vendor" "$DIR/system/vendor"
ln -sfn "$DIR/system/bin" "$DIR/bin"
ln -sfn "$DIR/system/xbin" "$DIR/xbin"


echo -e "${BLUE}[*]${RESET} Installing APEX runtime"

cp -a /apex/com.android.runtime "$DIR/apex/"


echo -e "${BLUE}[*]${RESET} Installing binaries"

for bin in \
sh \
toybox \
linker \
linker64
do
    if [ -f "/system/bin/$bin" ]; then
        cp "/system/bin/$bin" "$DIR/system/bin/"
    fi
done


echo -e "${BLUE}[*]${RESET} Linking APEX bionic libraries"

BIONIC="$DIR/apex/com.android.runtime/lib64/bionic"

if [ -d "$BIONIC" ]; then

    ln -sfn \
    "/apex/com.android.runtime/lib64/bionic/libc.so" \
    "$DIR/system/lib64/libc.so"

    ln -sfn \
    "/apex/com.android.runtime/lib64/bionic/libdl.so" \
    "$DIR/system/lib64/libdl.so"

    ln -sfn \
    "/apex/com.android.runtime/lib64/bionic/libm.so" \
    "$DIR/system/lib64/libm.so"

else
    echo "[-] Bionic libraries not found"
    exit 1
fi


echo -e "${BLUE}[*]${RESET} Installing system libraries"

for lib in \
libc++.so \
libz.so \
liblog.so \
libselinux.so \
libcrypto.so \
libcurl.so \
libpcre2.so \
libpackagelistparser.so
do
    if [ -f "/system/lib64/$lib" ]; then
        cp "/system/lib64/$lib" "$DIR/system/lib64/"
    fi
done


echo -e "${BLUE}[*]${RESET} Installing vendor libraries"

for lib in \
libc++.so \
libz.so \
liblog.so \
libselinux.so \
libcrypto.so
do
    if [ -f "/vendor/lib64/$lib" ]; then
        cp "/vendor/lib64/$lib" "$DIR/vendor/lib64/"
    fi
done


echo -e "${BLUE}[*]${RESET} Installing toybox commands"

cd "$DIR/system/bin"

if [ -f toybox ]; then
    for cmd in $(./toybox); do
        ln -sf toybox "$cmd"
    done
fi

cd /


echo -e "${BLUE}[*]${RESET} Installing linker config"

cp -a /linkerconfig/* "$DIR/linkerconfig/" 2>/dev/null || true


echo -e "${BLUE}[*]${RESET} Creating properties"

cat > "$DIR/system/build.prop" <<EOF
ro.product.model=generic_cli
ro.build.version.sdk=$SDK
ro.build.type=eng
ro.build.tags=test-keys
ro.debuggable=1
ro.secure=0
ro.github=rebangkkuser/androidcli
EOF


cat > "$DIR/vendor/build.prop" <<EOF
ro.vendor.product.model=generic_cli
ro.vendor.build.type=eng
ro.vendor.github=rebangkkuser/androidcli
EOF


cat > "$DIR/default.prop" <<EOF
ro.secure=0
ro.debuggable=1
persist.sys.usb.config=adb
EOF


echo -e "${BLUE}[*]${RESET} Installing clim"

mkdir -p "$DIR/vendor/bin"

cp ./clim "$DIR/vendor/bin/clim"
chmod 755 "$DIR/vendor/bin/clim"


echo -e "${BLUE}[*]${RESET} Installing startacli"

mkdir -p /data/local/bin

cat > /data/local/bin/startacli <<'EOF'
#!/system/bin/sh

if [ "$(id -u)" != 0 ]; then
    exec su -c "$0" "$@"
fi

env -i \
HOME=/root \
PATH=/system/bin:/vendor/bin \
LD_LIBRARY_PATH=/system/lib64:/vendor/lib64:/apex/com.android.runtime/lib64/bionic \
ACLI_VBP=/vendor/build.prop \
ACLI_SBP=/system/build.prop \
LOCALHOST=127.0.0.1 \
PM=aclim \
chroot \
/data/local/androcli \
/system/bin/sh
EOF

chmod 755 /data/local/bin/startacli


echo
echo -e "${GREEN}[+]${RESET} AndroidCLI installed."
echo -e "${GREEN}[+]${RESET} Run: startacli"
