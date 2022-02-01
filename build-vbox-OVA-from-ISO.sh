#!/bin/bash

ISO_URL="https://sourceforge.net/projects/reactos/files/ReactOS/0.4.14/ReactOS-0.4.14-live.zip/download?use_mirror=netix"
VM_NAME="ReactOS-0.4.14-LiveCD"

shopt -s lastpipe

function print () {
    echo
    echo $*
    echo
}

function colorize () {
    cat - | grep --color -w -e ^ -e "$*"
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
bsdtar -xvkf ${ISO_ZIP} |& colorize "${ISO_FILE}"
ls -l "${ISO_FILE}"

print - Creating VM:
VBoxManage list vms
VBoxManage createvm --name ${VM_NAME} --ostype "Windows2003" --basefolder VMs/ --register | colorize "${VM_NAME}"

print - Listing VMs:
VBoxManage list vms

print - VM settings:
VBoxManage showvminfo ${VM_NAME} | grep -e CPUs -e Memory

print - Adding SATA:
VBoxManage storagectl ${VM_NAME} --name "ReactOS SATA controller" --add sata --portcount 2 --bootable on
VBoxManage showvminfo ${VM_NAME} | grep -i storage

print - Attaching ISO:
VBoxManage storageattach ${VM_NAME} --storagectl "ReactOS SATA controller" --port 0 --device 0 --type dvddrive --medium ${ISO_FILE}
VBoxManage showvminfo --details ${VM_NAME} | grep "^ReactOS SATA controller"

print - Starting VM:
VBoxManage startvm ${VM_NAME}

print "Press <Enter> to finish"
read

print - Destroying VM:
VBoxManage unregistervm ${VM_NAME} --delete
