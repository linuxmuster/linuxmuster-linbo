#!/bin/sh
# License: GPL v2
# Martin Oehler 2007 <oehler@knopper.net>
#
# $1 is the path to the patch file
# $2 is the path to the windows system root
#
# thomas@linuxmuster.net
# 28.09.2015
#

# trust in this code
if [ -f "$1" ]; then
	echo "Registry wird gepatcht...bitte ein wenig Geduld."
else
	echo "Patchdatei $1 nicht gefunden!"
	exit 1
fi

# set DEBUG to "-v" to generate a LOT of debugging messages
DEBUG=""
hive=""
logfile="/tmp/output"

leftchop(){
  echo "$1" | cut -d \\ -f 2-
} 

leftget(){
  echo "$1" | cut -d \\ -f 1
}

leftgetvalue(){
  echo "$1" | cut -d \= -f 1
}

rightgetvalue(){
  echo "$1" | cut -d \= -f 2
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
 if [ -n "$1" ]; then
  cmd="cd $1\nls\nq\ny\n"
 else
  cmd="ls\nq\ny\n"
 fi
 echo -e "$cmd" | reged -e "$hive" | grep -i "<${2}>" | cut -d \< -f 2 | cut -d \> -f 1
}

# create_fullkey key (creates the full key path if necessary)
create_fullkey() {
 local key="$1"
 local tpath=""
 local bpath=""
 local cmd=""
 local i=""
 local OIFS="$IFS"

 [ -n "$DEBUG" ] && echo " 5 key=$key" | tee -a $logfile
 # remove right end and replace it with a backslash
 key=`rightchopend "$key"`
 local fullpath="$key"

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
   if [ -n "$bpath" ]; then
    cmd="cd ${bpath}\nnk ${tpath}\nq\ny\n"
   else
    cmd="nk ${tpath}\nq\ny\n"
   fi
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

# create_key key
create_key() {
 local key="$1"
 local key_new=""
 local i=""
 create_fullkey "$key"
 case "$key" in
  *ControlSet001*)
   for i in ControlSet002 ControlSet003; do
    if [ -n "$(test_key "" "$i")" ]; then
     key_new=`echo "$key" | sed -e "s|ControlSet001|$i|")`
     create_fullkey "$key_new"
    fi 
   done
  ;;
 esac
}

# parse change to value
create_command() {

 local key="$1"
 local change="$2"
 local fullpath=`rightchopend "$key"`

 [ -n "$DEBUG" ] && echo " 7 change=$change" | tee -a $logfile

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

 local basecommand="${command}"

 # get case sensitive parameter name from registry
 local found=""
 found="$(test_key "$fullpath" "$parameter")"
 [ -n "$found" ] && parameter="$found"
 [ -n "$DEBUG" ] && echo "16 found=$found" | tee -a $logfile

 # value is empty and parameter was not found in registry
 if [ -z "$value" -a -z "$found" ]; then
  command="${basecommand}nv ${type} ${parameter}\nq\ny\n"
 # value is set and parameter was not found in registry
 elif [ -n "$value" -a -z "$found" ]; then
  command="${basecommand}nv ${type} ${parameter}\ned ${parameter}\n$value\nq\ny\n"
 # value is empty and parameter is already present in registry
 elif [ -z "$value" -a -n "$found" ]; then
  command="${basecommand}dv ${parameter}\nnv ${type} ${parameter}\nq\ny\n"
 # value is set and parameter is already present in registry
 elif [ -n "$value" -a -n "$found" ]; then
  command="${basecommand}ed ${parameter}\n$value\nq\ny\n"
 fi

 # execute command
 [ -n "$DEBUG" ] && echo "17 command=$command" | tee -a $logfile
 exec_command "$command"
}

# read patch file
while read -r line; do
 [ -n "$DEBUG" ] && echo "$line $((count++))" | tee -a $logfile

 # select hive for patching
 case "$line" in 
  \[HKEY_LOCAL_MACHINE*) 
   tkey="$(leftchop "$line")"
   [ -n "$DEBUG" ] && echo " 1 tkey=$tkey" | tee -a $logfile

   case `leftget "$tkey"` in
    [Ss][Yy][Ss][Tt][Ee][Mm]*) 
     hive="$(ls -1d $2/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Yy][Ss][Tt][Ee][Mm] 2>/dev/null | tail -1)"
     [ -z "$hive" ] && hive="$(ls -1d $2/[Ww][Ii][Nn][Nn][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Yy][Ss][Tt][Ee][Mm] 2>/dev/null | tail -1)"
     # strip hive
     key=`leftchop "$tkey"`
     [ -n "$DEBUG" ] && echo " 2 key=$key" | tee -a $logfile

     # change "CurrentControlSet" to "ControlSet001"
     key="$(echo "$key" | sed 's,CurrentControlSet,ControlSet001,')"
     [ -n "$DEBUG" ] && echo " 3 key=$key" | tee -a $logfile
     ;;
    [Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee]*) 
     hive="$(ls -1d $2/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2>/dev/null | tail -1)"
     [ -z "$hive" ] && hive="$(ls -1d $2/[Ww][Ii][Nn][Nn][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2>/dev/null | tail -1)"
     # strip hive
     key=`leftchop "$tkey"`
     [ -n "$DEBUG" ] && echo " 4 key=$key" | tee -a $logfile
     ;;
    *) key="" ;;
   esac

   [ -n "$key" ] && create_key "$key"
   continue
  ;;
  \[HKEY_CURRENT_USER*) # yannik's pull request to patch default user's registry
   tkey="$(leftchop "$line")"
   [ -n "$DEBUG" ] && echo " 1 tkey=$tkey" | tee -a $logfile
   hive="$(ls -1d $2/[Dd][Oo][Kk][Uu][Mm][Ee][Nn][Tt][Ee]" "[Uu][Nn][Dd]" "[Ee][Ii][Nn][Ss][Tt][Ee][Ll][Ll][Uu][Nn][Gg][Ee][Nn]/[Dd][Ee][Ff][Aa][Uu][Ll][Tt]" "[Uu][Ss][Ee][Rr]/[Nn][Tt][Uu][Ss][Ee][Rr].[Dd][Aa][Tt] 2>/dev/null | tail -1)"
   [ -f "$hive" ] || hive="$(ls -1d $2/[Dd][Oo][Cc][Uu][Mm][Ee][Nn][Tt][Ss]" "[Aa][Nn][Dd]" "[Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]/[Dd][Ee][Ff][Aa][Uu][Ll][Tt]" "[Uu][Ss][Ee][Rr]/[Nn][Tt][Uu][Ss][Ee][Rr].[Dd][Aa][Tt] 2>/dev/null | tail -1)"
   [ -f "$hive" ] || hive="$(ls -1d $2/[Uu][Ss][Ee][Rr][Ss]/[Dd][Ee][Ff][Aa][Uu][Ll][Tt]" "[Uu][Ss][Ee][Rr]/[Nn][Tt][Uu][Ss][Ee][Rr].[Dd][Aa][Tt] 2>/dev/null | tail -1)"
   [ -f "$hive" ] || hive="$(ls -1d $2/[Uu][Ss][Ee][Rr][Ss]/[Dd][Ee][Ff][Aa][Uu][Ll][Tt]/[Nn][Tt][Uu][Ss][Ee][Rr].[Dd][Aa][Tt] 2>/dev/null | tail -1)"
   [ -n "$DEBUG" ] && echo " 2 hive=$hive" | tee -a $logfile

   key="$tkey"
   [ -n "$DEBUG" ] && echo " 3 key=$key" | tee -a $logfile

   [ -n "$key" ] && create_key "$key"
   continue
   ;;
  esac

 # check for valid line
 [ "${line:0:1}" = "\"" -a -n "$key" ] || continue

 # patches the value found in line
 create_command "$key" "$line"

 # patch other controlsets up to 3
 case "$key" in
  *ControlSet001*)
   for i in ControlSet002 ControlSet003; do
    echo "### Checking $i ..."
	   if [ -n "$(test_key "" "$i")" ]; then
	    key_new=`echo "$key" | sed -e "s|ControlSet001|$i|"`
	    [ -n "$DEBUG" ] && echo "### Patching $i ..." | tee -a $logfile
     create_command "$key_new" "$line"
	   fi
	  done
	 ;;
 esac

done < "$1" # while read -r line

