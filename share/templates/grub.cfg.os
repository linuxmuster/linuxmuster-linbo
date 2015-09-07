# group specific grub.cfg template for linbo net boot, should work with linux and windows operating systems
# thomas@linuxmuster.net
# 07.09.2015
#

# default #@@nr@@
menuentry '@@osname@@' {

 set root="@@osroot@@"

 if [ -e /vmlinuz -a -e /initrd.img ]; then
  linux /vmlinuz root=@@partition@@ @@append@@
  initrd /initrd.img
 elif [ -e /vmlinuz -a -e /initrd ]; then
  linux /vmlinuz root=@@partition@@ @@append@@
  initrd /initrd
 elif [ -e /@@kernel@@ -a -e /@@initrd@@ ]; then
  linux /@@kernel@@ root=@@partition@@ @@append@@
  initrd /@@initrd@@
 elif [ -e /@@kernel@@ ]; then
  linux /@@kernel@@ root=@@partition@@ @@append@@
 elif [ -s /boot/grub/grub.cfg ] ; then
  configfile /boot/grub/grub.cfg
 elif [ "$grub_platform" = "pc" ]; then
  if [ -s /bootmgr ] ; then
   ntldr /bootmgr
  elif [ -s /ntldr ] ; then
   ntldr /ntldr
  elif [ -s /grldr ] ; then
   ntldr /grldr
  else
   chainloader +1
  fi
 elif [ -e /Windows/Boot/EFI/bootfwmg.efi ]; then
  chainloader /Windows/Boot/EFI/bootfwmg.efi
  boot
 else
  chainloader +1
 fi

}

