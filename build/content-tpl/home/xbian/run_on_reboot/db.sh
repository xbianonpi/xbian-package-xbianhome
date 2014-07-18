#!/bin/bash

[ "$(findmnt -n -o FSTYPE $(df /home/xbian/.xbmc/userdata/Database|tail -1|awk '{print $6}'))" != btrfs ] && exit 0


checkdb() {
    cd "$1"
    for f in $(ls); do
        diff -q "$1/$f" "$1.old/$f"
        [ "$?" -eq 0 ] || return 1
    done
    return 0
}
# set noCoW flag for database files
for d in $(find /home/xbian/.xbmc/ -type d | grep -w Database$); do
    mv "$d" "$d.old"
    mkdir "$d"
    chattr +C "$d"
    cp -r $d.old/* "$d"
    if checkdb "$d"; then
        rm -fr "$d".old
        chown -Rc xbian:xbian "$d" > /dev/null
    else
        rm -fr "$d"
        mv "$d".old "$d"
        exit 1
    fi 
done 

exit 0
