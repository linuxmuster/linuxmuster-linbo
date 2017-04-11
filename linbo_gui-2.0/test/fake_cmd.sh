#!/usr/bin/env bash

# set to empty / comment out for ONLINE mode
OFFLINE=true

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then
    DIR="${PWD}"
fi
# shellcheck source=fake_cmd_functions.sh
. "${DIR}/fake_cmd_functions.sh"
# shellcheck source=fake_cmd_create.sh
. "${DIR}/fake_cmd_create.sh"
# shellcheck source=fake_cmd_upload.sh
. "${DIR}/fake_cmd_upload.sh"
# shellcheck source=fake_cmd_initcache.sh
. "${DIR}/fake_cmd_initcache.sh"

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
        start "$@"
        ;;
    partition_noformat)
        # doesn't use parameters, doesn't output something essential
        exit 0
        ;;
    partition)
        # see above
        exit 0
        ;;
    preregister)
        preregister "$@"
        ;;
    initcache)
        initcache "$@"
        ;;
    initcache_format)
        initcache "$@"
        ;;
    mountcache)
        mountcache "$@"
        ;;
    readfile)
        readfile "$@"
        ;;
    ready)
        # script is always ready :-)
        exit 0
        ;;
    register)
        register "$@"
        ;;
    sync)
        synconly "$@"
        ;;
    syncstart)
        synconly "$@"
        ;;
    syncr)
        synconly "$@"
        ;;
    synconly)
        synconly "$@"
        ;;
    update)
        update "$@"
        ;;
    upload)
        upload "$@"
        ;;
    version)
        version
        ;;
    writefile)
        writefile "$@"
        ;;
    *)
        help
        ;;
esac
