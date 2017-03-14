#!/usr/bin/env bash

# linbo_cmd ip
ip()
{
    if [[ -n "${OFFLINE}" ]]; then
        echo "OFFLINE"
    else
        echo "10.16.3.68"
    fi
}

# linbo_cmd hostname
hostname()
{
    echo "cpqmathe045"
}

# linbo_cmd cpu
cpu()
{
    for i in $(seq 1 2); do
        echo "Intel(R) Celeron(R) CPU  N2830  @ 2.16GHz"
    done
}

# linbo_cmd memory
memory()
{
    echo "1895 MB"
}

# linbo_cmd mac
mac()
{
    if [[ -n "${OFFLINE}" ]]; then
        echo "OFFLINE"
    else
        echo "54:A0:50:4C:3F:46"
    fi
}

# linbo_cmd size /dev/sda?
size()
{
    local disk="${1}"
    case "${disk}" in
        "/dev/sda")
            echo "465.8GB"
            ;;
        "/dev/sda1")
            echo "2.7/14.6GB"
            ;;
        "/dev/sda2")
            echo "2.0GB"
            ;;
        "/dev/sda3")
            echo "0.2/0.2GB"
            ;;
        "/dev/sda4")
            echo "408.2/441.4GB"
            ;;
        *)
            echo "Error: Could not stat device ${disk} - No such file or directory."
            exit 0
            ;;
    esac
}

# linbo_cmd battery
battery()
{
    echo "$((RANDOM%100))"
}

# linbo_cmd authenticate 10.16.1.1 linbo pw123
authenticate()
{
    local server="$1"
    local user="$2"
    local password="$3"
    if [[ "${server}" != "10.16.1.1" ]] \
      || [[ "${user}" != "linbo" ]] \
      || [[ "${password}" != "pw123" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    else
        return 0
    fi
}

# linbo_cmd start /dev/sda1 /dev/sda1 /boot/vmlinuz /boot/initrd "resume=/dev/sda2 splash=silent quiet showopts" /dev/sda4
# linbo_cmd start /dev/sda1 /dev/sda1 /boot/vmlinuz /boot/initrd "noresume splash=silent quiet showopts klassenarbeit=1" /dev/sda4
start()
{
    local boot="$1"
    local root="$2"
    local kernel="$3"
    local initrd="$4"
    local append="$5"
    local cache="$6"
    if [[ "${boot}" != "/dev/sda1" ]] \
      || [[ "${root}" != "/dev/sda1" ]] \
      || [[ "${kernel}" != "/boot/vmlinuz" ]] \
      || [[ "${initrd}" != "/boot/initrd" ]] \
      || [[ "${cache}" != "/dev/sda4" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    elif [[ "${append}" == "resume=/dev/sda2 splash=silent quiet showopts" ]] \
      || [[ "${append}" == "noresume splash=silent quiet showopts klassenarbeit=1" ]]; then
        return 0
    else
        echo "Wrong parameters: «$*»"
        return 1
    fi
}

# linbo_cmd preregister 10.16.1.1
# writes to /tmp/newregister
preregister()
{
    if [[ "${1}" != "10.16.1.1" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    else
        echo "mobil,x200ma,cpqmathe045,10.16.1.2"
        return 0
    fi
}

# linbo_cmd mountcache /dev/sda4 [options]
mountcache()
{
    local partition="$1"
    if [[ "${partition}" != "/dev/sda4" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    else
        shift
        echo "Mountcache options: «$*»"
        return 0
    fi
}

# linbo_cmd readfile /dev/sda4 filename [destinationfile]
readfile()
{
    local cachepartition="$1"
    local filename="$2"
    if [[ "${cachepartition}" != "/dev/sda4" ]] \
      || [[ -z "${filename}" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    else
        return 0
    fi
}

# linbo_cmd register 10.16.1.1 linbo pw123 room client ip group
register()
{
    local server="$1"
    local user="$2"
    local password="$3"
    local room="$4"
    local client="$5"
    local ip="$6"
    local group="$7"
    if [[ "${server}" != "10.16.1.1" ]] \
      || [[ "${user}" != "linbo" ]] \
      || [[ "${password}" != "pw123" ]] \
      || [[ -n "$8" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    else
        return 0
    fi
}

# linbo_cmd synconly 10.16.1.1 /dev/sda4 opensuse-cpqmini.cloop "" /dev/sda1 /dev/sda1 /boot/vmlinuz /boot/initrd "resume=/dev/sda2 splash=silent quiet showopts"
# linbo_cmd synconly 10.16.1.1 /dev/sda4 opensuse-cpqmini.cloop "" /dev/sda1 /dev/sda1 /boot/vmlinuz /boot/initrd "noresume splash=silent quiet showopts klassenarbeit=1"
synconly()
{
    # TODO: check $baseimage $image
    local server="$1"
    local cachedev="$2"
    local baseimage="$3"
    local image="$4"
    local bootdev="$5"
    local rootdev="$6"
    local kernel="$7"
    local initrd="$8"
    local append="$9"
    if [[ "${server}" != "10.16.1.1" ]] \
      || [[ "${cachedev}" != "/dev/sda4" ]] \
      || [[ "${baseimage}" != "opensuse-cpqmini.cloop" ]] \
      || [[ "${image}" != "" ]] \
      || [[ "${bootdev}" != "/dev/sda1" ]] \
      || [[ "${rootdev}" != "/dev/sda1" ]] \
      || [[ "${kernel}" != "/boot/vmlinuz" ]] \
      || [[ "${initrd}" != "/boot/initrd" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    elif [[ "${append}" == "resume=/dev/sda2 splash=silent quiet showopts" ]] \
      || [[ "${append}" == "noresume splash=silent quiet showopts klassenarbeit=1" ]]; then
        return 0
    else
        echo "Wrong append parameters: «$*»"
        return 1
    fi
}

# linbo_cmd update 10.16.1.1 /dev/sda4 [force]
update()
{
    local server="$1"
    local cachedev="$2"
    local force="$3"
    if [[ "${server}" != "10.16.1.1" ]] \
      || [[ "${cachedev}" != "/dev/sda4" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    else
        return 0
    fi
}

# linbo_cmd version
version()
{
    echo "LINBO 3.0.0-1"
}

# linbo_cmd writefile /dev/sda4 filename
writefile()
{
    local cachepartition="$1"
    local filename="$2"
    if [[ "${cachepartition}" != "/dev/sda4" ]] \
      || [[ -z "${filename}" ]]; then
        echo "Wrong parameters: «$*»"
        return 1
    else
        return 0
    fi
}

# linbo_cmd *
help()
{
    echo "You didn't really expect you would get any help from this script, did you?" 1>&2
}
