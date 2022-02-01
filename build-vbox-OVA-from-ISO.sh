#!/bin/bash

ISO_URL="https://sourceforge.net/projects/reactos/files/ReactOS/0.4.14/ReactOS-0.4.14-iso.zip/download?use_mirror=netix"
VM_NAME="ReactOS-0.4.14-LiveCD"

shopt -s lastpipe

ISO_ZIP_="${ISO_URL%/*}"
ISO_ZIP_="${ISO_ZIP_##*/}"
# TODO: either use ${ISO_FILE} as the made up output filename,
#       or just calculat it from the `wget` output in some way:

echo; echo - Retrieving:
wget -nv --show-progress -c --content-disposition ${ISO_URL}
ls -l "${ISO_ZIP_}"

echo; echo - Extracting:
bsdtar -tvf ${ISO_ZIP_} \
        | awk '/iso$/ {$1=$2=$3=$4=$5=$6=$7=$8=""; print}' \
        | read ISO_FILE
bsdtar -xvkf ${ISO_ZIP_} \
        |& grep --color -e ^ -e "${ISO_FILE}"
ls -l "${ISO_FILE}"

echo; echo - Creating VM:
VBoxManage createvm --name ${VM_NAME} --ostype "Windows2003" --basefolder VMs/ --register

echo; echo - Destroying VM:
VBoxManage unregistervm ${VM_NAME} --delete
