#!/usr/bin/env bash
# Dateien löschen, um Platz zu sparen
set -e
shopt -s extglob

sed -i '/\/dev\/root/d' "${TARGET_DIR}"/etc/fstab

rm -fv "${TARGET_DIR}"/usr/lib/fonts/!(DejaVuSans.ttf)
rm -fv "${TARGET_DIR}"/etc/dropbear
rm -fvr "${TARGET_DIR}"/usr/lib/qt/plugins/bearer/
rm -fvr "${TARGET_DIR}"/usr/lib/qt/plugins/imageformats/
rm -fv "${TARGET_DIR}"/usr/lib/qt/generic/!(libqlibinputplugin.so)
rm -fv "${TARGET_DIR}"/usr/lib/qt/plugins/platforms/!(libqlinuxfb.so)
rm -fv "${TARGET_DIR}"/usr/lib/libQt5Network.so*
rm -fv "${TARGET_DIR}"/usr/lib/libQt5PrintSupport.so*
rm -fv "${TARGET_DIR}"/usr/lib/libQt5Sql.so*
rm -fv "${TARGET_DIR}"/usr/lib/libQt5Test.so*
rm -fv "${TARGET_DIR}"/usr/lib/libQt5Xml.so*
rm -fv "${TARGET_DIR}"/usr/bin/b{more,vedit,view}
rm -fv "${TARGET_DIR}"/usr/bin/grub-{file,fstest,glue-efi,menulst2cfg,mklayout,mknetdir,mkpasswd-pbkdf2,mkrescue,mkstandalone,render-label,script-check,syslinux2cfg}
rm -fv "${TARGET_DIR}"/usr/sbin/grub-{macbless,sparc64-setup}
rm -fv "${TARGET_DIR}"/usr/bin/pcretest

# benötigte Verzeichnisse erstellen
mkdir -p "${TARGET_DIR}"/cache

# set DIR variables
COMMON_DIR="${BASE_DIR}"/../../files/common
LMN6_DIR="${BASE_DIR}"/../../files/lmn6
LINBOFS_DIR="${BASE_DIR}"/../../linbofs

# create target copy of grub.cfg.local
cp -v "${COMMON_DIR}"/usr/share/linuxmuster-linbo/templates/grub.cfg.local "${TARGET_DIR}"/usr/share/grub/grub.cfg

# copy files from lmn6, linbofs to target dir
cp -v "${LINBOFS_DIR}"/etc/linbo-version "${TARGET_DIR}"/etc/linbo-version
cp -v "${LINBOFS_DIR}"/etc/newdev-patch.bvi "${TARGET_DIR}"/etc/newdev-patch.bvi
cp -v "${LINBOFS_DIR}"/etc/inittab "${TARGET_DIR}"/etc/inittab
cp -v "${LINBOFS_DIR}"/etc/inittab.tty1 "${TARGET_DIR}"/etc/inittab.tty1
cp -v "${LINBOFS_DIR}"/usr/bin/linbo_cmd "${TARGET_DIR}"/usr/bin/linbo_cmd
cp -v "${LINBOFS_DIR}"/usr/bin/linbo_wrapper "${TARGET_DIR}"/usr/bin/linbo_wrapper
cp -v "${LINBOFS_DIR}"/bin/patch_registry "${TARGET_DIR}"/usr/bin/patch_registry
mkdir -p "${TARGET_DIR}"/usr/share/udhcpc/default.script.d
cp -v "${LINBOFS_DIR}"/usr/share/udhcpc/default.script "${TARGET_DIR}"/usr/share/udhcpc/default.script.d/linbo.sh
cp -rv "${COMMON_DIR}"/linbo/icons "${TARGET_DIR}"
cp -v "${TARGET_DIR}"/icons/linbo_wallpaper_800x600.png "${TARGET_DIR}"/icons/linbo_wallpaper.png
cp -rv "${COMMON_DIR}"/linbo/linuxmuster-win "${TARGET_DIR}"
cp -v "${COMMON_DIR}"/linbo/german.kbd "${TARGET_DIR}"/usr/share/de-latin1-nodeadkeys.kmap
