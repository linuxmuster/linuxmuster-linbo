#!/bin/sh
# linbo.sh - Start Linbo GUI (with optional debug shell before)
# This is a busybox 1.1.3 script
# (C) Klaus Knopper 2007
# License: GPL V2
# thomas@linuxmuster.net
# 20201204
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
  local isoboot
  local offline
  local download
  local md5sum_local
  local md5sum_server
  if uname -a | grep -q x86_64; then
    bits="64"
  else
    bits="32"
  fi
  local gui_prefix="linbo_gui${bits}"
  local gui_archives="${gui_prefix}_7.tar.lz ${gui_prefix}.tar.lz"
  # check if isoboot and try to get linbo_gui archive from cdrom
  if cat /proc/cmdline | grep -wq isoboot; then
    echo "ISO/USB boot detected, trying to get linbo_gui from removable media." | tee -a /cache/linbo.log
    mkdir -p /media
    for i in /dev/disk/by-id/*; do
      if mount "$i" /media &> /dev/null; then
        # check for old and new gui versions on iso
        for a in $as; do
          if [ -s "/media/$a" ]; then
            tar xf "/media/$a" -C / || return 1
            isoboot="yes"
            break
          fi
        done
        umount /media &> /dev/null
      fi
      if [ -n "$isoboot" ]; then
        echo "Successfully installed linbo_gui from removable media." | tee -a /cache/linbo.log
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
    echo "Continuing without cache partition." | tee -a /cache/linbo.log
    # to avoid unmounting later
    cache_mounted="yes"
  else
    echo "Successfully mounted cache partition." | tee -a /cache/linbo.log
  fi
  # get network infos
  if ! . /tmp/network.ok; then
    echo "Fatal: Cannot read network infos. Continuing offline." | tee -a /cache/linbo.log
    offline="yes"
  fi
  # return if offline and no cache
  [ -n "$nocache" -a -n "$offline" ] && return 1

  # start linbo_gui update
  local curdir="$(pwd)"
  # change to cache if present
  [ -z "$nocache" ] && cd /cache

  # check for old and new gui versions to download
  for a in $gui_archives; do
    # skip if archive does not exist in offline mode
    [ ! -s "$a" -a -n "$offline" ] && continue
    # if network is present ...
    if [ -z "$offline" ]; then
      # force download if archive does not exist
      if [ -s "$a" -a -s "$a.md5" ]; then
        download="no"
      else
        rm -f "$a.md5"
        download="yes"
      fi
      # if archive already exists try to find out if there is a newer one on the server
      if [ "$download" = "no" ]; then
        # get md5sum of existing archive
        md5sum_local="$(md5sum "$a" | awk '{print $1}')"
        # get md5sum from server
        echo "Downloading $a.md5 from $linbo_server." | tee -a /cache/linbo.log
        rm -f "$a.md5"
        linbo_cmd download "$linbo_server" "$a.md5" 2>&1 | tee -a /cache/linbo.log
        if [ -s "$a.md5" ]; then
          md5sum_server="$(cat "$a.md5")"
        else
          echo "Download of $a.md5 failed!" | tee -a /cache/linbo.log
          # skip if md5sum cannot be downloaded
          continue
        fi
        # md5sums match, no download needed
        if [ "$md5sum_local" = "$md5sum_server" ]; then
          echo "$a is up-to-date. No need to download." | tee -a /cache/linbo.log
          download="no"
        else
          # md5sums differ, need to download archive
          download="yes"
        fi
      fi
      if [ "$download" = "yes" ]; then
        echo "Downloading $a from $linbo_server." | tee -a /cache/linbo.log
        linbo_cmd download "$linbo_server" "$a" 2>&1 | tee -a /cache/linbo.log
        # get md5sum file if not yet downloaded
        if [ ! -s "$a.md5" ]; then
          echo "Downloading $a.md5 from $linbo_server." | tee -a /cache/linbo.log
          linbo_cmd download "$linbo_server" "$a.md5" 2>&1 | tee -a /cache/linbo.log
        fi
      fi
    fi
    [ -s "$a" -a -s "$a.md5" ] && break
  done

  # unpack gui archive if present and healthy
  if [ -s "$a" -a -s "$a.md5" ]; then
    if [ "$(cat "$a.md5")" = "$(md5sum "$a" | awk '{print $1}')" ]; then
      tar xf "$a" -C / | tee -a /cache/linbo.log
    fi
  fi

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
case "$a" in
  # new gui
  *_7*)
    export XKB_DEFAULT_LAYOUT=de
    /usr/bin/linbo_gui -platform linuxfb
    ;;
  # legacy gui
  *)
    export QWS_KEYBOARD="TTY:keymap=/usr/share/qt/german_keymap.qmap"
    exec linbo_gui -qws >/tmp/linbo_gui.$$.log 2>&1
    ;;
esac
