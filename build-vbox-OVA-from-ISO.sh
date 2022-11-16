#!/bin/bash

# SPDX-FileCopyrightText: 2022 Saulius Krasuckas <saulius2@ar-fi.lt> | sskras
# SPDX-License-Identifier: BlueOak-1.0.0

 ISO_URL="https://sourceforge.net/projects/reactos/files/ReactOS/0.4.14/ReactOS-0.4.14-live.zip/download?use_mirror=netix"
#ISO_URL="http://www.cs.tohoku-gakuin.ac.jp/pub/Linux/ReactOS/ReactOS-0.4.14-live.zip"
VM_NAME="ReactOS-0.4.14-LiveCD"
SATA_NAME="ReactOS-SATA-controller"

shopt -s lastpipe
set -e

function print () {
    echo
    echo $*
    echo
}

function colorize () {
    grep --color -E -e "^" "$@"
}

ISO_ZIP="${ISO_URL%/*}"
ISO_ZIP="${ISO_ZIP##*/}"
# TODO: either use ${ISO_FILE} as the made up output filename,
#       or just calculat it from the `wget` output in some way:

print - Retrieving:
curl -# -L -N -R -o ${ISO_ZIP} -C - ${ISO_URL} \
	|| true  # Work around SF.net redirecting a request to resume a download of the already complete file to some sorry page.
ls -l "${ISO_ZIP}"

print - Extracting:
bsdtar -tvf ${ISO_ZIP} \
        | awk '/iso$/ {$1=$2=$3=$4=$5=$6=$7=$8=""; print}' \
        | read ISO_FILE
bsdtar -xvkf ${ISO_ZIP} |& colorize -e ${ISO_FILE}
ls -l "${ISO_FILE}"

print - Creating VM:
VBoxManage list vms
VBoxManage createvm --name ${VM_NAME} --ostype "Windows2003" --basefolder "${PWD}/VMs" --register | colorize -e ${VM_NAME}

print - Listing VMs:
VBoxManage list vms | colorize -e ${VM_NAME}

print - VM settings:
VBoxManage showvminfo ${VM_NAME} | grep -e CPUs -e Memory | colorize -e '[0-9MB]+$'

print - Adding SATA:
VBoxManage storagectl ${VM_NAME} --name ${SATA_NAME} --add sata --portcount 2 --bootable on
VBoxManage showvminfo ${VM_NAME} | grep -i storage | colorize -e ${SATA_NAME}

print - Attaching ISO:
VBoxManage storageattach ${VM_NAME} --storagectl ${SATA_NAME} --port 0 --device 0 --type dvddrive --medium ${ISO_FILE}
VBoxManage showvminfo --details ${VM_NAME} | grep "^${SATA_NAME}" | colorize -e ${SATA_NAME} -e "${ISO_FILE}"

print - VM net config:
VBoxManage showvminfo ${VM_NAME} | awk '/^NIC/ && !/^NIC .* disabled/' | colorize -e "^NIC +[0-9]+" -e "MAC: [^,]+" -e "Type: [^,]+"

print - Starting VM:
VBoxManage startvm ${VM_NAME} | colorize -e ${VM_NAME}

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

exit

VBoxManage natnetwork add --netname "NAT-network-OAM" --network "10.1.1.0/24" --enable
VBoxManage modifyvm ${VM0} --nic1 natnetwork --natnetwork1 "NAT-network-OAM"
VBoxManage showvminfo ${VM0} | grep "NIC"

VBoxManage modifyvm ${VM0} --uart1 ${UART_I_O_PORT} ${UART_IRQ} --uartmode1 tcpserver ${UART_TCP_PORT}
VBoxManage showvminfo ${VM0} | grep "UART"
VBoxManage controlvm ${VM0} pause
VBox_setup_serial_console ${VM0}

VBoxManage showmediuminfo disk "${VDI_FILE}" \
        | awk '/^UUID/ {print $2}' \
        | read VDI_UUID
VBoxManage showmediuminfo disk "${VDI_FILE}" #\
       #| grep --color -e $ -e "${VDI_UUID}"


VBoxManage dhcpserver remove --network "NAT-network-OAM"
VBoxManage natnetwork remove --netname "NAT-network-OAM"

# leftover

VBoxManage modifyvm ${VM0} --cpus ${VM_CPUS} --memory ${VM_RAM}
VBoxManage showvminfo ${VM0} | grep -e CPUs -e Memory
