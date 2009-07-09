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
file=""
tmplog="/tmp/output"
tmpctrls="/tmp/controlsets"
tmptest="/tmp/keytest"

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

do_reg() {
 local cmd="$1"
 local logfile="$2"
 [ -z "$logfile" ] && logfile="$tmplog"
 chntpw $DEBUG -e "$file" >> $logfile <<.
$(echo -e "$cmd")
.
}

test_key() {
 local path="$1"
 local key="$2"
 local RC=0
 local cmd="ls ${path}\nq\ny\n"
 [ -e "$tmptest" ] && rm $tmptest
 do_reg "$cmd" "$tmptest"
 grep -q "<${key}>" $tmptest || RC=1
 return $RC
}

create_key() {
 local path="$1"
 local key="$2"
 local cmd="cd ${path}\nnk ${key}\nq\ny\n"
 do_reg "$cmd"
}

create_cmd() {
 local key="$1"
 local ctrlset="$2"

 #####
 # parse path to value
 #####

 [ -n "$DEBUG" ] && echo "5  key=$key" | tee -a $tmplog
 # remove right end and replace it with a backslash
 key=`rightchopend "$key"`
 fullpath="$key"
 key="$key\\"

 [ -n "$DEBUG" ] && echo "6  fullpath=$fullpath" | tee -a $tmplog

 currentkey=`leftget "$key"`
 [ -n "$DEBUG" ] && echo "7  currentkey=$currentkey" | tee -a $tmplog

 key=`leftchop "$key"`
 [ -n "$DEBUG" ] && echo "8  key=$key" | tee -a $tmplog

 base_path=""
 while [ "$currentkey" != "" ]; do

  [ -z "$base_path" ] && base_path="."

  [ -n "$DEBUG" ] && echo "9  base_path=$base_path" | tee -a $tmplog

	# tschmitt: check if currentkey exists in registry, if not create it
	if ! test_key "$base_path" "$currentkey"; then
   if [ -n "$ctrlset" ]; then
    # don't create new keys in supplemental controlsets
    [ -n "$DEBUG" ] && echo "### Skipping creation of $currentkey in $ctrlset!" | tee -a $tmplog
    return 1
   fi
	 [ -n "$DEBUG" ] && echo "### Creating key $currentkey" | tee -a $tmplog
	 create_key "$base_path" "$currentkey"
	fi

	if [ "$base_path" = "." ]; then
	 base_path="${currentkey}"
	else
	 base_path="${base_path}\\${currentkey}"
	fi

  currentkey=`leftget "$key"`
  [ -n "$DEBUG" ] && echo "10 currentkey=$currentkey" | tee -a $tmplog

  key=`leftchop "$key"`
  [ -n "$DEBUG" ] && echo "11 key=$key" | tee -a $tmplog

 done

 base_command="cd ${fullpath}\n"
}

create_val() {
 ####
 # parse value changes
 ####
 [ -n "$DEBUG" ] && echo "12 change=$change" | tee -a $tmplog

 if [ "$change" = "" ]; then 
  return 1
 fi

 command="${base_command}"
 [ -n "$DEBUG" ] && echo "13 command=$command" | tee -a $tmplog

 parameter=`leftgetvalue "$change"`
 [ -n "$DEBUG" ] && echo "14 parameter=$parameter" | tee -a $tmplog

 parameter="$(echo "$parameter" | sed 's,\",,g')"
 [ -n "$DEBUG" ] && echo "15 parameter=$parameter" | tee -a $tmplog

 value=`rightgetvalue "$change"`
 [ -n "$DEBUG" ] && echo "16 value=$value" | tee -a $tmplog

 value="$(echo "$value" | sed 's,\",,g')"
 [ -n "$DEBUG" ] && echo "17 value=$value" | tee -a $tmplog
          
 value="$(echo "$value" | sed 's,$,,g')"
 [ -n "$DEBUG" ] && echo "18 value=$value" | tee -a $tmplog

 # our standard type for strings is REG_SZ
 type="1"
 case "$value" in
  dword*) value="$(echo "$value" | sed 's,^dword:,0x,g')"
          # set type to REG_DWORD
          type="4"
          ;;
 esac
 if [ -n "$DEBUG" ]; then
  echo "19 type=$type" | tee -a $tmplog
  echo "20 value=$value" | tee -a $tmplog
 fi

 command="${command}dv ${parameter}\n"
 command="${command}nv ${type} ${parameter}\n"
 [ -n "$DEBUG" ] && echo "21 command=$command" | tee -a $tmplog

 command="${command}ed ${parameter}\n"
 [ -n "$DEBUG" ] && echo "22 command=$command" | tee -a $tmplog

 command="${command}$value\nq\ny\n"
 [ -n "$DEBUG" ] && echo "23 command=$command" | tee -a $tmplog

 # out final command
 [ -n "$DEBUG" ] && echo "24 final command=$command" | tee -a $tmplog
}

while read -r key; do
  [ -n "$DEBUG" ] && echo "$key $((count++))" | tee -a $tmplog

  # select file for patching
  case "$key" in 
    \[HKEY_LOCAL_MACHINE*) 
      key="$(leftchop "$key")"
      [ -n "$DEBUG" ] && echo "1  key=$key" | tee -a $tmplog

      case `leftget "$key"` in
        [Ss][Yy][Ss][Tt][Ee][Mm]*) 
          file="$(ls -1d $2/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Yy][Ss][Tt][Ee][Mm] 2>/dev/null | tail -1)"
          [ -z "$file" ] && file="$(ls -1d $2/[Ww][Ii][Nn][Nn][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Yy][Ss][Tt][Ee][Mm] 2>/dev/null | tail -1)"
          # strip file
          key=`leftchop "$key"`
          [ -n "$DEBUG" ] && echo "2  key=$key" | tee -a $tmplog

          # change "CurrentControlSet" to "ControlSet001"
          key="$(echo "$key" | sed 's,CurrentControlSet,ControlSet001,')"
          [ -n "$DEBUG" ] && echo "3  key=$key" | tee -a $tmplog
          ;;
        [Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee]*) 
     	    file="$(ls -1d $2/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2>/dev/null | tail -1)"
     	    [ -z "$file" ] && file="$(ls -1d $2/[Ww][Ii][Nn][Nn][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2>/dev/null | tail -1)"
          # strip file
          key=`leftchop "$key"`
          [ -n "$DEBUG" ] && echo "4  key=$key" | tee -a $tmplog
          ;;
      esac

			create_cmd "$key"

      while read -r change; do

        create_val || break

        do_reg "$command"

				# tschmitt: patch other controlsets up to 9
        case "$command" in
          *ControlSet001*)
						if [ ! -s "$tmpctrls" ]; then
							[ -n "$DEBUG" ] && echo "### Writing $tmpctrls ..." | tee -a $tmplog
							controlcheck="ls\nq\ny\n"
							do_reg "$controlcheck" "$tmpctrls"
						fi
						n=2
						while [ $n -lt 10 ]; do
							ctrlset="ControlSet00$n"
							[ -n "$DEBUG" ] && echo "### Checking $ctrlset ..." | tee -a $tmplog
							if grep -q "<$ctrlset>" $tmpctrls; then
								key_new="$(echo "$key" | sed "s,ControlSet001,$ctrlset,")"
								[ -n "$DEBUG" ] && echo "### Patching $ctrlset with new key: $key_new" | tee -a $tmplog
								if create_cmd "$key_new" "$ctrlset"; then
									create_val
									do_reg "$command"
								fi
							fi
							let n+=1
						done
						;;
        esac

      done # while read -r change 
      ;;
  esac # case "$key"

done < "$1" # while read -r key

# merge logfiles
cat $tmplog >> $tmpctrls
mv $tmpctrls $tmplog

