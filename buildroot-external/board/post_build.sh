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
mkdir -p "${TARGET_DIR}"/icons
mkdir -p "${TARGET_DIR}"/linuxmuster-win
mkdir -p "${TARGET_DIR}"/usr/share/udhcpc/default.script.d

# copy templates to target
cp -v "${BASE_DIR}"/../../share/templates/grub.cfg.local.oss "${TARGET_DIR}"/usr/share/grub/grub.cfg
cp -v "${BASE_DIR}"/../../rpm/linbo_cmd.oss "${TARGET_DIR}"/usr/bin/linbo_cmd
# copy linbofs files to target
LINBOFS_DIR="${BASE_DIR}"/../../linbofs
cp -v "${LINBOFS_DIR}"/etc/linbo-version "${TARGET_DIR}"/etc/
cp -v "${LINBOFS_DIR}"/etc/newdev-patch.bvi "${TARGET_DIR}"/etc/newdev-patch.bvi
cp -v "${LINBOFS_DIR}"/bin/patch_registry "${TARGET_DIR}"/usr/bin/
cp -v "${LINBOFS_DIR}"/usr/share/udhcpc/default.script "${TARGET_DIR}"/usr/share/udhcpc/default.script.d/linbo.sh
sed 's@#!/bin/sh@#!/usr/bin/ash@' "${LINBOFS_DIR}"/usr/bin/linbo_wrapper >"${TARGET_DIR}"/usr/bin/linbo_wrapper
# copy linbo files to target
LINBO_DIR="${BASE_DIR}"/../../linbo
cp -v "${LINBO_DIR}"/icons/linbo_wallpaper_1024x768.png "${TARGET_DIR}"/icons/linbo_wallpaper.png
cp -v "${LINBO_DIR}"/linuxmuster-win/* "${TARGET_DIR}"/linuxmuster-win/
cp -v "${LINBO_DIR}"/german.kbd "${TARGET_DIR}"/usr/share/de-latin1-nodeadkeys.kmap
