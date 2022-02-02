#!/bin/bash

ISO_URL="https://sourceforge.net/projects/reactos/files/ReactOS/0.4.14/ReactOS-0.4.14-live.zip/download?use_mirror=netix"
VM_NAME="ReactOS-0.4.14-LiveCD"
SATA_NAME="ReactOS-SATA-controller"

shopt -s lastpipe

function print () {
    echo
    echo $*
    echo
}

function colorize () {
    cat - | grep --color -e "^" "$@"
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
bsdtar -xvkf ${ISO_ZIP} |& colorize -e "${ISO_FILE}"
ls -l "${ISO_FILE}"

print - Creating VM:
VBoxManage list vms
VBoxManage createvm --name ${VM_NAME} --ostype "Windows2003" --basefolder VMs/ --register | colorize -e "${VM_NAME}"

print - Listing VMs:
VBoxManage list vms

print - VM settings:
VBoxManage showvminfo ${VM_NAME} | grep -e CPUs -e Memory

print - Adding SATA:
VBoxManage storagectl ${VM_NAME} --name ${SATA_NAME} --add sata --portcount 2 --bootable on
VBoxManage showvminfo ${VM_NAME} | grep -i storage

print - Attaching ISO:
VBoxManage storageattach ${VM_NAME} --storagectl ${SATA_NAME} --port 0 --device 0 --type dvddrive --medium ${ISO_FILE}
VBoxManage showvminfo --details ${VM_NAME} | grep "^${SATA_NAME}"

print - VM net config:
VBoxManage showvminfo ${VM_NAME} | awk '/^NIC/ && !/^NIC .* disabled/' | colorize -e "MAC: [^,]\+" -e "Type: [^,]\+"

print - Starting VM:
VBoxManage startvm ${VM_NAME}

print "Press <Enter> to finish"
read

print - Powering VM off:
VBoxManage controlvm ${VM_NAME} poweroff
until $(VBoxManage showvminfo ${VM_NAME} | grep -q powered.off); do echo -n "."; sleep 1; done; sleep 2

print - Destroying VM:
VBoxManage unregistervm ${VM_NAME} --delete
#VBoxManage unregistervm ${VM0}
#rm -rv ${BASE_DIR}/VMs/${VM0}

print - Listing VMs:
VBoxManage list vms
