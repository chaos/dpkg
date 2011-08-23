#!/bin/bash

# Usage: quilt.sh project project-patched series patches

prog=quilt.sh
qopt=0
project=proj
ext=""
series=patches/series
patches=patches/patches

die() {
    echo "${prog}: $1" >&2
    exit 1
}

warn() {
    echo "${prog}: $1" >&2
}

usage() {
    echo "Usage: ${prog} [-q] [-p dir] [-e ext] [-s series] [-d patches]" 2>&1
    exit 1
}

list_patches() {
    cat ${top}/${series} | sed -e 's/#.*$//'
}

# quilt push will not error out on empty or missing patches
check_patches() {
    local patch
    for patch in $(list_patches); do
	[ -r ${top}/${patches}/${patch} ] || die "couldn't read ${patch}"
    done
}

#
# main
#

top=$(pwd)
quilt=$(which quilt)
[ -n ${quilt} ] || die "could not find quilt in your PATH"
rpm -qf ${quilt} | grep chaos >/dev/null \
    || warn "WARNING: non-chaos quilt ok for setup/push, not for patch editing"
lndir=$(which lndir)
[ -n ${lndir} ] || die "could not find lndir in your PATH"

while getopts qp:e:s:d: opt; do
    case "$opt" in
        q) qopt=1 ;;
        p) project=$OPTARG ;;
        e) ext=${OPTARG} ;;
        s) series=$OPTARG ;;
        d) patches=$OPTARG ;;
        *) usage ;;
    esac
done

[ -d ${project} ] || die "project directory not found: ${project}"
[ -r ${series} ] || die "cannot read series file: ${series}"
[ -d ${patches} ] || die "patch directory not found: ${patches}"
patched=${project}${ext:+"+${ext}"}

# make sure all patches in series exist
warn "checking patches"
check_patches

# create link-copy if -e was provided
if [ ${patched} != ${project} ]; then
    rm -rf ${patched} 
    mkdir ${patched} || exit 1
    pushd ${patched} >/dev/null
        warn "creating link-copy of ${project}"
        ${lndir} -silent ${top}/${project}
    popd >/dev/null
fi

# link patches into working copy
ln -sf ${top}/${series} ${patched}/series
ln -sf ${top}/${patches} ${patched}/patches

warn "patching ${patched} with series ${series}"
pushd ${patched} >/dev/null
    quilt setup series # ignore return code
    if [ $(list_patches | wc -l) -gt 0 ]; then 
        quilt push -a ${qopt:+"-q"} || die "quilt push -a failed"
    fi
popd >/dev/null

exit 0
