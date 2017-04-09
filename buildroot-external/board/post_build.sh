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

# create target copy of grub.cfg.local
cp -v "${BASE_DIR}"/../../share/templates/grub.cfg.local "${TARGET_DIR}"/usr/share/grub/grub.cfg
