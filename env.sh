#!/system/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
    exec su -c "$0" "$@"
fi

clear

DIR="/data/local/androcli"

GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"

printf "${GREEN}"

if command -v figlet >/dev/null 2>&1; then
    figlet androidcli
else
cat <<'EOF'
       _           _     _      _ _
  __ _ _ __   __| |_ __ ___ (_) __| | ___| (_)
 / _` | '_ \ / _` | '__/ _ \| |/ _` |/ __| | |
| (_| | | | | (_| | | | (_) | | (_| | (__| | |
 \__,_|_| |_|\__,_|_|  \___/|_|\__,_|\___|_|_|
EOF
fi

printf "${RESET}"

echo "AndroidCLI Installer v0.2.0 alpha 2"
echo "github.com/rebangkkuser/androidcli"
echo

echo -e "${BLUE}[*]${RESET} Checking environment..."

SDK="$(getprop ro.build.version.sdk)"

if [ "$SDK" -lt 29 ]; then
    echo "[-] Android 10 or newer is required."
    exit 1
fi

if [ ! -d "/apex/com.android.runtime" ]; then
    echo "[-] APEX runtime was not found."
    exit 1
fi

echo -e "${GREEN}[+]${RESET} Android SDK: $SDK"
echo -e "${GREEN}[+]${RESET} APEX runtime detected"

echo -e "${BLUE}[*]${RESET} Creating filesystem..."

mkdir -p \
"$DIR/system/bin" \
"$DIR/system/xbin" \
"$DIR/system/lib64" \
"$DIR/system/apex" \
"$DIR/vendor/bin" \
"$DIR/vendor/xbin" \
"$DIR/vendor/lib64" \
"$DIR/vendor/apex" \
"$DIR/apex" \
"$DIR/dev" \
"$DIR/proc" \
"$DIR/sys" \
"$DIR/linkerconfig"


ln -sfn "$DIR/vendor" "$DIR/system/vendor"
ln -sfn "$DIR/system/bin" "$DIR/bin"
ln -sfn "$DIR/system/xbin" "$DIR/xbin"


echo -e "${BLUE}[*]${RESET} Installing APEX runtime..."

cp -a "/apex/com.android.runtime" "$DIR/apex/"


echo -e "${BLUE}[*]${RESET} Installing system binaries..."

for binary in \
toybox \
linker \
linker64 \
sh
do
    if [ -f "/system/bin/$binary" ]; then
        cp "/system/bin/$binary" "$DIR/system/bin/$binary"
    fi
done


echo -e "${BLUE}[*]${RESET} Installing toybox..."

cd "$DIR/system/bin"

if [ -f toybox ]; then
    for cmd in $(./toybox); do
        ln -sf toybox "$cmd"
    done
fi

cd /


echo -e "${BLUE}[*]${RESET} Installing vendor tools..."

if [ -f "/vendor/bin/toybox_vendor" ]; then

    cp "/vendor/bin/toybox_vendor" \
    "$DIR/vendor/bin/toybox_vendor"

    cd "$DIR/vendor/bin"

    for cmd in $(./toybox_vendor); do
        ln -sf toybox_vendor "$cmd"
    done

    cd /

fi


echo -e "${BLUE}[*]${RESET} Installing linker configuration..."

if [ -d "/linkerconfig" ]; then
    cp -a /linkerconfig/* "$DIR/linkerconfig/" 2>/dev/null || true
fi


echo -e "${BLUE}[*]${RESET} Mounting kernel interfaces..."

mount --bind /dev "$DIR/dev"
mount --bind /proc "$DIR/proc"
mount --bind /sys "$DIR/sys"


echo -e "${BLUE}[*]${RESET} Creating properties..."

cat > "$DIR/system/build.prop" <<EOF
ro.product.model=generic_cli
ro.product.name=generic_cli
ro.product.device=generic_cli
ro.build.version.sdk=$SDK
ro.build.type=eng
ro.build.tags=test-keys
ro.debuggable=1
ro.secure=0
ro.cli.home=/root
ro.github=rebangkkuser/androcli
EOF


cat > "$DIR/vendor/build.prop" <<EOF
ro.vendor.product.model=generic_cli
ro.vendor.product.name=generic_cli
ro.vendor.build.version.sdk=$SDK
ro.vendor.build.type=eng
ro.vendor.build.tags=test-keys
ro.vendor.github=rebangkkuser/androcli
EOF


cat > "$DIR/default.prop" <<EOF
ro.secure=0
ro.debuggable=1
persist.sys.usb.config=adb
EOF


chmod -R 755 "$DIR/system/bin" 2>/dev/null || true
chmod -R 755 "$DIR/vendor/bin" 2>/dev/null || true


echo
echo -e "${GREEN}[+]${RESET} AndroidCLI installation finished."
echo -e "${GREEN}[+]${RESET} RootFS: $DIR"
echo -e "${GREEN}[+]${RESET} Completed at $(date +%H:%M:%S)"
