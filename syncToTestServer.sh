#!/bin/bash

VM_IP=10.9.0.1

rsync -avzp --chown 0:0 ./files/lmn7/ root@$VM_IP:/

inotifywait -r -m -e close_write --format '%w%f' ./files/lmn7/ | while read MODFILE
do
    echo need to rsync ${MODFILE%/*} ...
    rsync -avzp --chown 0:0 ./files/lmn7/ root@$VM_IP:/
done