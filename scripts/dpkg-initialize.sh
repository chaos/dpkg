#!/bin/bash

admindir=/usr/local/dpkg-db

set -e
umask 022
if [ ! -d ${admindir} ]; then
    mkdir -m 0755 ${admindir}
fi
for file in status available statoverride diversions dpkg.log; do
    [ -f ${admindir}/${file} ] || touch ${admindir}/${file}
done
for dir in info methods parts updates; do
    [ -d ${admindir}/${dir} ] || mkdir ${admindir}/${dir}
done

exit 0
