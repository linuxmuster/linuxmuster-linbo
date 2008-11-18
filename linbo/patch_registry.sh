#!/bin/sh
# License: GPL v2
# Martin Oehler 2007 <oehler@knopper.net>

# $1 is the path to the patch file
# $2 is the path to the windows system root

# trust in this code
echo "Registry wird gepatcht...bitte ein wenig Geduld."

# this generates a LOT of debugging messages
DEBUG="-v"
file=""

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

if [ -f "$1" ]; then
  while read -r key; do

    if [ -n "$DEBUG" ]; then
      echo "$key $((count++))"
    fi

    # select file for patching
    case "$key" in 
      \[HKEY_LOCAL_MACHINE*) 
        key="$(leftchop "$key")"
        if [ -n "$DEBUG" ]; then
          echo "1  key=$key"
        fi

        case `leftget "$key"` in
          [Ss][Yy][Ss][Tt][Ee][Mm]*) 
	          file="$(ls -1d $2/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Yy][Ss][Tt][Ee][Mm] 2>/dev/null | tail -1)"
	          [ -z "$file" ] && file="$(ls -1d $2/[Ww][Ii][Nn][Nn][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Yy][Ss][Tt][Ee][Mm] 2>/dev/null | tail -1)"
            # strip file
            key=`leftchop "$key"`
            if [ -n "$DEBUG" ]; then
              echo "2  key=$key"
            fi

            # change "CurrentControlSet" to "ControlSet001"
            key="$(echo "$key" | sed 's,CurrentControlSet,ControlSet001,')"
            if [ -n "$DEBUG" ]; then
              echo "3  key=$key"
            fi
            ;;
          [Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee]*) 
      	    file="$(ls -1d $2/[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2>/dev/null | tail -1)"
      	    [ -z "$file" ] && file="$(ls -1d $2/[Ww][Ii][Nn][Nn][Tt]/[Ss][Yy][Ss][Tt][Ee][Mm]32/[Cc][Oo][Nn][Ff][Ii][Gg]/[Ss][Oo][Ff][Tt][Ww][Aa][Rr][Ee] 2>/dev/null | tail -1)"
            # strip file
            key=`leftchop "$key"`
            if [ -n "$DEBUG" ]; then
              echo "4  key=$key"
            fi
            ;;
        esac

        #####
        # parse path to value
        #####

        if [ -n "$DEBUG" ]; then
          echo "5  key=$key"
        fi
        # remove right end and replace it with a backslash
        key=`rightchopend "$key"`
        key="$key\\"

        if [ -n "$DEBUG" ]; then
          echo "6  key=$key"
        fi
        
        currentkey=`leftget "$key"`
        if [ -n "$DEBUG" ]; then
          echo "7  currentkey=$currentkey"
        fi

        key=`leftchop "$key"`
        if [ -n "$DEBUG" ]; then
          echo "8  key=$key"
        fi

        base_command=""
        while [ "$currentkey" != "" ]; do
          if [ -n "$DEBUG" ]; then
            echo "9  currentkey=$currentkey"
          fi

          base_command="${base_command}nk $currentkey\ncd $currentkey\n"
          currentkey=`leftget "$key"`
          if [ -n "$DEBUG" ]; then
            echo "10 currentkey=$currentkey"
          fi

          key=`leftchop "$key"`
          if [ -n "$DEBUG" ]; then
            echo "11  key=$key"
          fi

        done

        ####
        # parse value changes
        ####

        while read -r change; do
          if [ -n "$DEBUG" ]; then
            echo "12 change=$change"
          fi

          if [ "$change" = "" ]; then 
            break
          fi

          command="${base_command}"
          if [ -n "$DEBUG" ]; then
            echo "13 command=$command"
          fi

          parameter=`leftgetvalue "$change"`
          if [ -n "$DEBUG" ]; then
            echo "14 parameter=$parameter"
          fi

          parameter="$(echo "$parameter" | sed 's,\",,g')"
          if [ -n "$DEBUG" ]; then
            echo "15 parameter=$parameter"
          fi

          value=`rightgetvalue "$change"`
          if [ -n "$DEBUG" ]; then
            echo "16 value=$value"
          fi

          value="$(echo "$value" | sed 's,\",,g')"
          if [ -n "$DEBUG" ]; then
            echo "17 value=$value"
          fi
          
          value="$(echo "$value" | sed 's,$,,g')"
          if [ -n "$DEBUG" ]; then
            echo "18 value=$value"
          fi

          # our standard type for strings is REG_SZ
          type="1"
          case "$value" in
            dword*) value="$(echo "$value" | sed 's,^dword:,0x,g')"
                    # set type to REG_DWORD
                    type="4"
                    ;;
          esac
          if [ -n "$DEBUG" ]; then
            echo "19 type=$type"
            echo "20 value=$value"
          fi

          command="${command}dv ${parameter}\n"
          command="${command}nv ${type} ${parameter}\n"
          if [ -n "$DEBUG" ]; then
            echo "21 command=$command"
          fi

          command="${command}ed ${parameter}\n"
          if [ -n "$DEBUG" ]; then
            echo "22 command=$command"
          fi
          
          command="${command}$value\nq\ny\n"
          if [ -n "$DEBUG" ]; then
            echo "23 command=$command"
          fi

          # out final command
          if [ -n "$DEBUG" ]; then
            echo "24 final command=$command"
            echo ""
          fi
          chntpw $DEBUG -e "$file" >> /tmp/output <<.
$(echo -e "$command")
.
# tschmitt: this destroys the system registry hive in WinXP SP3
#          case "$command" in
#            *ControlSet001*)
#          command="$(echo "$command" | sed 's,ControlSet001,ControlSet002,g')"
#          chntpw $DEBUG -e "$file" >> /tmp/output <<.
#$(echo -e "$command")
#.
#            ;;
#          esac
        done 
        ;;
    esac  
  done < "$1"
fi

