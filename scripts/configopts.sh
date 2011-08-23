#!/bin/bash

echo "\
--with-admindir=/usr/local/dpkg-db --without-selinux --without-libiconv-prefix \
--without-start-stop-daemon --without-libintl-prefix --with-included-gettext \
--disable-linker-optimisations --disable-nls --without-dselect"
exit 0
