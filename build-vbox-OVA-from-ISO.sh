#!/bin/bash

ISO_URL_="https://sourceforge.net/projects/reactos/files/ReactOS/0.4.14/ReactOS-0.4.14-iso.zip/download?use_mirror=netix"

shopt -s lastpipe

ISO_ZIP_="${ISO_URL_%/*}"
ISO_ZIP_="${ISO_ZIP_##*/}"
# TODO: either use ${ISO_FILE} as the made up output filename,
#       or just calculat it from the `wget` output in some way:

echo; echo Retrieving:
wget -nv --show-progress -c --content-disposition ${ISO_URL_}
ls -l "${ISO_ZIP_}"

echo; echo Extracting:
bsdtar -tvf ${ISO_ZIP_} \
        | awk '/iso$/ {$1=$2=$3=$4=$5=$6=$7=$8=""; print}' \
        | read ISO_FILE
bsdtar -xvkf ${ISO_ZIP_} \
        |& grep --color -e ^ -e "${ISO_FILE}"
ls -l "${ISO_FILE}"
