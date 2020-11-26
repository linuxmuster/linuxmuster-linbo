#!/bin/sh
# linbo.sh - Start Linbo GUI (with optional debug shell before)
# This is a busybox 1.1.3 script
# (C) Klaus Knopper 2007
# License: GPL V2
# thomas@linuxmuster.net
# 20201124
#

# Reset fb color mode
RESET="]R"
# Clear and reset Screen
CLEAR="c"

CMDLINE="$(cat /proc/cmdline)"

# echo "$CLEAR$RESET"

# get linbo_gui
get_linbo_gui(){
  # get bits
  local bits
  if uname -a | grep -q x86_64; then
    bits="64"
  else
    bits="32"
  fi
  local gui_archive="linbo_gui${bits}.tar.lz"
  # check if isoboot and try to get linbo_gui archive from cdrom
  if cat /proc/cmdline | grep -wq isoboot; then
    echo "ISO/USB boot detected, trying to get linbo_gui from removable media."
    mkdir -p /media
    for i in /dev/disk/by-id/*; do
      if mount "$i" /media &> /dev/null; then
        if [ -s "/media/$gui_archive" ]; then
          tar xf "/media/$gui_archive" -C / && local isoboot="yes"
        fi
        umount /media &> /dev/null
      fi
      if [ -n "$isoboot" ]; then
        echo "Successfully installed linbo_gui from removable media."
        return 0
      fi
    done
  fi
  echo "Trying to download linbo_gui from server to cache."
  mount | grep -q /cache && local cache_mounted="yes"
  if [ -z "$cache_mounted" ]; then
    local cachedev="$(cat /tmp/linbo-cache.done)"
    local nocache
    if [ -n "$cachedev" ]; then
      if ! linbo_cmd mount "$cachedev" /cache; then
        nocache="yes"
      fi
    else
      nocache="yes"
    fi
  fi
  if [ -n "$nocache" ]; then
    echo "Continuing without cache partition."
    # to avoid unmounting later
    cache_mounted="yes"
  else
    echo "Successfully mounted cache partition."
  fi
  # get network infos
  if ! . /tmp/network.ok; then
    echo "Fatal: Cannot read network infos."
    return 1
  fi
  # start linbo_gui update
  local curdir="$(pwd)"
  # change to cache if present
  [ -z "$nocache" ] && cd /cache
  [ -s "$gui_archive.md5" ] && local md5sum_local="$(cat "$gui_archive.md5")"
  echo "Dowloading $gui_archive.md5 from $linbo_server."
  linbo_cmd download "$linbo_server" "$gui_archive.md5" 2>&1 | tee /cache/linbo.log
  if [ -s "$gui_archive.md5" ]; then
    local md5sum_server="$(cat "$gui_archive.md5")"
  else
    echo "Download of $gui_archive.md5 failed!"
    return 1
  fi
  if [ "$md5sum_local" = "$md5sum_server" -a -n "$md5sum_local" -a -n "$md5sum_server" ]; then
    echo "$gui_archive is up-to-date. No need to download."
  else
    echo "Dowloading $gui_archive from $linbo_server."
    linbo_cmd download "$linbo_server" "$gui_archive" 2>&1 | tee /cache/linbo.log
  fi
  tar xf "$gui_archive" -C / | tee /cache/linbo.log
  # leave cache if present
  [ -z "$nocache" ] && cd "$curdir"
  [ -z "$cache_mounted" ] && umount /cache
  if [ -s /usr/bin/linbo_gui ]; then
    echo "Successfully installed linbo_gui from cache."
    return 0
  else
    echo "Failed to install linbo_gui from cache."
    return 1
  fi
}

# DEBUG
case "$CMDLINE" in *\ debug*)
    for i in /tmp/linbo_gui.*.log; do
      if [ -s "$i" ]; then
        echo "There is a logfile from a previous start of linbo_gui in $i::"
        cat "$i"
        echo -n "Press enter key to continue."
        read dummy
        rm -f "$i"
      fi
    done
    echo "Starting DEBUG shell, leave with 'exit'."
    ash >/dev/tty1 2>&1 < /dev/tty1
    ;;
esac

# download linbo_gui from server to cache
if ! get_linbo_gui; then
  case "$CMDLINE" in
    *\ debug*)
      echo "Starting DEBUG shell."
      ash >/dev/tty1 2>&1 < /dev/tty1
      ;;
    *)
      echo -e "\nPress [1] to reboot or [2] to shutdown."
      local answer="0"
      while [ "$answer" != "1" -a "$answer" != "2" ]; do
        read answer
        case "$answer" in
          1) /sbin/reboot ;;
          2) /sbin/poweroff ;;
          *) ;;
        esac
      done
      ;;
  esac
fi

# Start LINBO GUI
#DISPLAY=""
# not necessary anymore?
#case "$(fbset 2>/dev/null)" in *640x480*) DISPLAY="-display VGA16:0";; esac
export QWS_KEYBOARD="TTY:keymap=/usr/share/qt/german_keymap.qmap"
#exec linbo_gui -qws $DISPLAY >/tmp/linbo_gui.$$.log 2>&1
exec linbo_gui -qws >/tmp/linbo_gui.$$.log 2>&1
