# androidcli - android but on CLI lines
![acli](https://raw.githubusercontent.com/rebangkkuser/androidcli/refs/heads/main/assets/androidcli.png)
androidcli is a project by bangkkuser that uses the Android Shell with extra features, without any CLI. 
# Why use?
Fun, study, testing or development 
# How to use?
First, you need an Android device to extract the files (if you want to run it on a Linux computer). Run the following commands.
```bash
curl -O https://raw.githubusercontent.com/rebangkkuser/androidcli/refs/heads/main/env.sh
```
```bash
chmod 755 env.sh
```
```bash
./env.sh
```
Warning: env.sh have Android shebang and files. You need to manually adapt it for Linux/iOS.
Run with
```bash
su -c '
env -i \
HOME=/root \
TERM=xterm-256color \
chroot /data/local/androcli /system/bin/sh
'
```
## Pages
[Wiki]()
