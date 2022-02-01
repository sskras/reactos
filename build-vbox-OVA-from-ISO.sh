#!/bin/bash

ISO_URL="https://sourceforge.net/projects/reactos/files/ReactOS/0.4.14/ReactOS-0.4.14-iso.zip/download?use_mirror=netix"
VM_NAME="ReactOS-0.4.14-LiveCD"

shopt -s lastpipe

function print () {
    echo
    echo $*
    echo
}

ISO_ZIP="${ISO_URL%/*}"
ISO_ZIP="${ISO_ZIP##*/}"
# TODO: either use ${ISO_FILE} as the made up output filename,
#       or just calculat it from the `wget` output in some way:

print - Retrieving:
wget -nv --show-progress -c --content-disposition ${ISO_URL}
ls -l "${ISO_ZIP}"

print - Extracting:
bsdtar -tvf ${ISO_ZIP} \
        | awk '/iso$/ {$1=$2=$3=$4=$5=$6=$7=$8=""; print}' \
        | read ISO_FILE
bsdtar -xvkf ${ISO_ZIP} \
        |& grep --color -e ^ -e "${ISO_FILE}"
ls -l "${ISO_FILE}"

print - Creating VM:
VBoxManage list vms
VBoxManage createvm --name ${VM_NAME} --ostype "Windows2003" --basefolder VMs/ --register

print - Listing VMs:
VBoxManage list vms

print "Press <Enter> to finish"
read

print - Destroying VM:
VBoxManage unregistervm ${VM_NAME} --delete
