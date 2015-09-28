# group specific grub.cfg template for linbo net boot, should work with linux and windows operating systems
# thomas@linuxmuster.net
# 28.09.2015
#

# default #@@nr@@
menuentry '@@osname@@' {

 set root="@@osroot@@"
 set win_efiloader="/EFI/Microsoft/Boot/bootmgfw.efi"
 
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
 elif [ -e "$win_efiloader" ]; then
  chainloader $win_efiloader
  boot
 fi

}

