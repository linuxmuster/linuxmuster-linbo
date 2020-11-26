#!/bin/sh
#
# creates linbo_gui distribution archives
# thomas@linuxmuster.net
# 20201124
# GPL V3
#

# get force parameter
[ "$1" = "-f" -o "$1" = "--force" ] && FORCE="yes"

# must be invoked in root of linuxmuster-linbo build tree
CURDIR="$(pwd)"

# build 32 & 64bit linbo_gui archives
for i in 32 64; do
  cd "$CURDIR"
  TMPDIR=tmp/$i
  rm -rf "$TMPDIR"
  CONF="conf/linbo_gui${i}.conf"
  ARCHIVE="linbo_gui${i}/linbo_gui${i}.tar.lz"
  if [ -s "$ARCHIVE" -a -s "$ARCHIVE.md5" -a -z "$FORCE" ]; then
    echo "Skipping existing $ARCHIVE."
    continue
  fi
  echo -n "Creating $ARCHIVE ... "
  mkdir -p "$TMPDIR"
  grep ^dir "$CONF" | while read line; do
    DIR="$(echo "$line" | awk '{print $2}')"
    PERM="$(echo "$line" | awk '{print $3}')"
    if [ -z "$DIR" -o -z "$PERM" ]; then
      echo "Error with $CONF!"
      exit 1
    fi
    mkdir -p "$TMPDIR/$DIR"
    chmod "$PERM" "$TMPDIR/$DIR" || exit 1
  done
  grep ^file "$CONF" | while read line; do
    TARGET="$(echo "$line" | awk '{print $2}')"
    SOURCE="$(echo "$line" | awk '{print $3}')"
    PERM="$(echo "$line" | awk '{print $4}')"
    if [ -z "$TARGET" -o -z "$SOURCE" -o -z "$PERM" ]; then
      echo "Error with $CONF!"
      exit 1
    fi
    cp -L "$SOURCE" "$TMPDIR/$TARGET"
    chmod "$PERM" "$TMPDIR/$TARGET"
  done
  cd "$TMPDIR"
  tar --lzma  -cf "$CURDIR/$ARCHIVE" * || exit 1
  md5sum "$CURDIR/$ARCHIVE" | awk '{print $1}' > "$CURDIR/$ARCHIVE.md5" || exit 1
  echo "Done!"
done
