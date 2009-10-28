#!/bin/sh
# License: GPL v2
# Martin Oehler 2007 <oehler@knopper.net>
#
# $1 is the path to the patch file
# $2 is the path to the windows system root
#
# Thomas Schmitt <schmitt@lmz-bw.de>
# 23.10.2009
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
 reged $DEBUG -e "$hive" >> $logfile <<.
$(echo -e "$cmd")
.
}

# test_key basepath key (returns case sensitive key name or nothing)
test_key() {
 local cmd=""
# local RET=""
 if [ -n "$1" ]; then
  cmd="cd $1\nls\nq\ny\n"
 else
  cmd="ls\nq\ny\n"
 fi
 echo -e "$cmd" | reged -e "$hive" | grep -i "\<$2\>" | awk -F\< '{ print $2 }' | awk -F\> '{ print $1 }' | grep -i "$2"
# RET="$(echo -e "$cmd" | reged -e "$hive" | grep -i "\<$2\>" | awk -F\< '{ print $2 }' | awk -F\> '{ print $1 }')"
# echo "$RET" | grep -i $2
}

create_keypath() {
 local key="$1"
 local tpath=""
 local bpath=""
 local cmd=""
 local i=""
 local OIFS="$IFS"

 #####
 # parse path to value
 #####

 [ -n "$DEBUG" ] && echo " 5 key=$key" | tee -a $logfile
 # remove right end and replace it with a backslash
 key=`rightchopend "$key"`
 fullpath="$key"

 [ -n "$DEBUG" ] && echo " 6 fullpath=$fullpath" | tee -a $logfile

 # iterate over path chunks and create keys if necessary
 IFS="\\"
 for i in $fullpath; do
  # get case sensitive key name from registry
  tpath="$(test_key "$bpath" "$i")"
  # create the key if test_key returns an empty key name
  if [ -z "$tpath" ]; then
   [ -n "$DEBUG" ] && echo "### Creating new key $bpath $i" | tee -a $logfile
   tpath="$i"
   cmd="cd ${bpath}\nnk ${tpath}\nq\ny\n"
   exec_command "$cmd"
  fi
  if [ -n "$bpath" ]; then
   bpath="${bpath}\\${tpath}"
  else
   bpath="$tpath"
  fi
 done
 IFS="$OIFS"
 fullpath="$bpath"
}

create_command() {
 ####
 # parse value changes
 ####
 [ -n "$DEBUG" ] && echo " 7 change=$change" | tee -a $logfile
 [ "${change// /}" = "" ] && return 1

 command="cd ${fullpath}\n"
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

 local basecommand="${command}"

 # get real case sensitive parameter name from registry
 local found=""
 found="$(test_key "$fullpath" "$parameter")"
 [ -n "$found" ] && parameter="$found"

 # value is empty and parameter was not found in registry
 if [ -z "$value" -a -z "$found" ]; then
  command="${basecommand}nv ${parameter}\nq\ny\n"
 # value is set and parameter was not found in registry
 elif [ -n "$value" -a -z "$found" ]; then
  command="${basecommand}nv ${parameter}\ned ${parameter}\n$value\nq\ny\n"
 # value is empty and parameter is already present in registry
 elif [ -z "$value" -a -n "$found" ]; then
  command="${basecommand}dv ${parameter}\nnv ${parameter}\nq\ny\n"
 # value is set and parameter is already present in registry
 elif [ -n "$value" -a -n "$found" ]; then
  command="${basecommand}ed ${parameter}\n$value\nq\ny\n"
 fi

 # execute command
 exec_command "$command"
 [ -n "$DEBUG" ] && echo "16 command=$command" | tee -a $logfile
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
			    if [ -n "$(test_key "" "$ctrlset")" ]; then
			     key="$(echo "$key" | sed "s,ControlSet00[1-9],$ctrlset,")"
				    [ -n "$DEBUG" ] && echo "### Patching $ctrlset ..." | tee -a $logfile
				    create_keypath "$key" && create_command
			    fi
			    let n+=1
		    done
		    ;;
    esac

   done # while read -r change 
   ;;
 esac # case "$key"

done < "$1" # while read -r key

