#!/usr/bin/env bash

ip()
{
    if [[ -n "${OFFLINE}" ]]; then
        echo "OFFLINE"
    else
        echo "10.16.3.68"
    fi
}

hostname()
{
    echo "cpqmathe045"
}

cpu()
{
    for i in $(seq 1 2); do
        echo "Intel(R) Celeron(R) CPU  N2830  @ 2.16GHz"
    done
}

memory()
{
    echo "1895 MB"
}

mac()
{
    if [[ -n "${OFFLINE}" ]]; then
        echo "OFFLINE"
    else
        echo "54:A0:50:4C:3F:46"
    fi
}

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

battery()
{
    echo "$((RANDOM%100))"
}

authenticate()
{
    local server="${1}"
    local user="${2}"
    local password="${3}"
    if [[ "${server}" != "10.16.1.1" ]] || [[ "${user}" != "linbo" ]] || [[ "${password}" != "pw123" ]]; then
        return 1
    else
        return 0
    fi
}

version()
{
    echo "LINBO 2.3.0-99"
}

help()
{
    echo "You didn't really expect you would get any help from this script, did you?" 1>&2
}
