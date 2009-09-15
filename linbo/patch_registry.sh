#!/bin/sh
# License: GPL v2
# Martin Oehler 2007 <oehler@knopper.net>
#
# $1 is the path to the patch file
# $2 is the path to the windows system root
#
# Thomas Schmitt <schmitt@lmz-bw.de>
# 20.04.2009
#

# trust in this code
if [ -f "$1" ]; then
	echo "Registry wird gepatcht...bitte ein wenig Geduld."
else
	echo "Patchdatei $1 nicht gefunden!"
	exit 1
fi

# this generates a LOT of debugging messages
DEBUG="-v"
hive=""
logfile="/tmp/output"

leftchop(){
  echo "$1" | cut -d \\ -f 2-
} 

leftget(){
  echo "$1" | awk -F\\ '{print $1}' 
}

leftgetvalue(){
  echo "$1" | awk -F'=' '{print $1}'
}

rightgetvalue(){
  echo "$1" | awk -F'=' '{print $2}'
}

rightchopend(){
  echo "$1" | sed 's,]$,,' | sed 's,\\$,,'
}

exec_command() {
 local cmd="$1"
 chntpw $DEBUG -e "$hive" >> $logfile <<.
$(echo -e "$cmd")
.
}

test_key() {
 local key="$1"
 local RC=1
 echo -e "cd $key\nq\ny\n" | chntpw -e "$hive" | grep -q "not found\!" || RC="0"
 return $RC
}

create_key() {
 local fpath="$1"
 local tpath=""
 local bpath=""
 local cmd=""
 local i=""
 local OIFS="$IFS"
 IFS="\\"
 for i in $fpath; do
  bpath="$tpath"
  if [ -n "$tpath" ]; then tpath="${tpath}\\${i}"; else tpath="$i"; fi
  if ! test_key "$tpath"; then
   if [ "$bpath" = "" ]; then
    cmd="nk ${i}\nq\ny\n"
   else
    cmd="cd ${bpath}\nnk ${i}\nq\ny\n"
   fi
   exec_command "$cmd"
  fi
 done
 IFS="$OIFS"
}

create_keypath() {
 local key="$1"
 local ctrlset="$2"

 #####
 # parse path to value
 #####

 [ -n "$DEBUG" ] && echo " 5 key=$key" | tee -a $logfile
 # remove right end and replace it with a backslash
 key=`rightchopend "$key"`
 fullpath="$key"

 [ -n "$DEBUG" ] && echo " 6 fullpath=$fullpath" | tee -a $logfile

	# tschmitt: check if currentkey exists in registry, if not create it
	if ! test_key "$fullpath"; then
#  if [ -n "$ctrlset" ]; then
#   # don't create new keys in supplemental controlsets
#   [ -n "$DEBUG" ] && echo "### Skipping $fullpath" | tee -a $logfile
#   return 1
#  fi
	 [ -n "$DEBUG" ] && echo "### Creating key $fullpath" | tee -a $logfile
	 create_key "$fullpath"
	fi
}

# returns success if old value is equal to new value
test_value(){
 local fpath="$1"
 local newval="$2"
 local curval="$(echo -e "cat ${fpath}\nq\ny\n" | chntpw -e "$hive" | grep -Fi "$newval")"
 if [ -n "$curval" ]; then
  [ -n "$DEBUG" ] && echo "### $parameter is already set to $curval. Skipping." | tee -a $logfile
  return 0
 else
  [ -n "$DEBUG" ] && echo "### $parameter is not equal to $newval. Patching." | tee -a $logfile
  return 1
 fi
}

create_command() {
 ####
 # parse value changes
 ####
 [ -n "$DEBUG" ] && echo " 7 change=$change" | tee -a $logfile
 [ "${change// /}" = "" ] && return 1

 local command="cd ${fullpath}\n"
 [ -n "$DEBUG" ] && echo " 8 command=$command" | tee -a $logfile

 local parameter=`leftgetvalue "$change"`
 [ -n "$DEBUG" ] && echo " 9 parameter=$parameter" | tee -a $logfile

 parameter="$(echo "$parameter" | sed 's,\",,g')"
 [ -n "$DEBUG" ] && echo "10 parameter=$parameter" | tee -a $logfile

 local value=`rightgetvalue "$change"`
 [ -n "$DEBUG" ] && echo "11 value=$value" | tee -a $logfile

 value="$(echo "$value" | sed 's,\",,g')"
 [ -n "$DEBUG" ] && echo "12 value=$value" | tee -a $logfile

 value="$(echo "$value" | sed 's,$,,g')"
 [ -n "$DEBUG" ] && echo "13 value=$value" | tee -a $logfile

 # our standard type for strings is REG_SZ
 local type="1"
 case "$value" in
  dword*) value="$(echo "$value" | sed 's,^dword:,0x,g')"
          # set type to REG_DWORD
          type="4"
          ;;
 esac
 if [ -n "$DEBUG" ]; then
  echo "14 type=$type" | tee -a $logfile
  echo "15 value=$value" | tee -a $logfile
 fi

 # return if value is already set -> nothing to do
# if [ -n "$value" ]; then
#  test_value "${fullpath}\\${parameter}" "$value" && return 1
# fi

 local basecommand="${command}"

 # delete value
 command="${basecommand}dv ${parameter}\nq\ny\n"
 exec_command "$command"
 [ -n "$DEBUG" ] && echo "16 command=$command" | tee -a $logfile

 # create value
 command="${basecommand}nv ${type} ${parameter}\nq\ny\n"
 exec_command "$command"
 [ -n "$DEBUG" ] && echo "17 command=$command" | tee -a $logfile

 # edit value
 command="${basecommand}ed ${parameter}\n$value\nq\ny\n"
 exec_command "$command"
 [ -n "$DEBUG" ] && echo "18 command=$command" | tee -a $logfile
}

while read -r key; do
 [ -n "$DEBUG" ] && echo "$key $((count++))" | tee -a $logfile

 # select hive for patching
 case "$key" in 
  \[HKEY_LOCAL_MACHINE*) 
   key="$(leftchop "$key")"
   [ -n "$DEBUG" ] && echo " 1 key=$key" | tee -a $logfile

   case `leftget "$key"` in
    [Ss][Yy][Ss][Tt][Ee][Mm]*) 
     hive="$(ls -1d $2/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Yy][Ss][Tt][Ee][Mm] 2>/dev/null | tail -1)"
     [ -z "$hive" ] && hive="$(ls -1d $2/[Ww][Ii][Nn][Nn][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Yy][Ss][Tt][Ee][Mm] 2>/dev/null | tail -1)"
     # strip hive
     key=`leftchop "$key"`
     [ -n "$DEBUG" ] && echo " 2 key=$key" | tee -a $logfile

     # change "CurrentControlSet" to "ControlSet001"
     key="$(echo "$key" | sed 's,CurrentControlSet,ControlSet001,')"
     [ -n "$DEBUG" ] && echo " 3 key=$key" | tee -a $logfile
     ;;
    [Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee]*) 
     hive="$(ls -1d $2/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2>/dev/null | tail -1)"
     [ -z "$hive" ] && hive="$(ls -1d $2/[Ww][Ii][Nn][Nn][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2>/dev/null | tail -1)"
     # strip hive
     key=`leftchop "$key"`
     [ -n "$DEBUG" ] && echo " 4 key=$key" | tee -a $logfile
     ;;
   esac

   create_keypath "$key"

   while read -r change; do

    create_command || break

	  # tschmitt: patch other controlsets up to 3
    case "$command" in
     *ControlSet001*)
		    n=2
		    while [ $n -lt 4 ]; do
			    ctrlset="ControlSet00$n"
			    [ -n "$DEBUG" ] && echo "### Checking $ctrlset ..." | tee -a $logfile
			    if test_key "$ctrlset"; then
			     key_new="$(echo "$key" | sed "s,ControlSet001,$ctrlset,")"
				    [ -n "$DEBUG" ] && echo "### Patching $ctrlset with new key: $key_new" | tee -a $logfile
				    create_keypath "$key_new" "$ctrlset" && create_command
			    fi
			    let n+=1
		    done
		    ;;
    esac

   done # while read -r change 
   ;;
 esac # case "$key"

done < "$1" # while read -r key

