#!/usr/bin/env bash

# set to empty / comment out for ONLINE mode
OFFLINE=true

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then
    DIR="${PWD}"
fi
# shellcheck source=fake_cmd_functions.sh
. "${DIR}/fake_cmd_functions.sh"
. "${DIR}/fake_cmd_create.sh"

cmd="${1}"
if [[ -n "${cmd}" ]]; then
    shift
fi

case "${cmd}" in
    ip)
        ip
        ;;
    hostname)
        hostname
        ;;
    cpu)
        cpu
        ;;
    memory)
        memory
        ;;
    mac)
        mac
        ;;
    size)
        size "$@"
        ;;
    battery)
        battery
        ;;
    authenticate)
        authenticate "$@"
        ;;
    create)
        create "$@"
        ;;
    start)
        return 0
        ;;
    partition_noformat)
        ;;
    partition)
        ;;
    preregister)
        ;;
    initcache)
        ;;
    initcache_format)
        ;;
    mountcache)
        ;;
    readfile)
        ;;
    ready)
        ;;
    register)
        ;;
    sync)
        ;;
    syncstart)
        ;;
    syncr)
        ;;
    synconly)
        ;;
    update)
        ;;
    upload)
        ;;
    version)
        version
        ;;
    writefile)
        ;;
    *)
        help
        ;;
esac
