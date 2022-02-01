#!/bin/bash

ISO_URL_="https://sourceforge.net/projects/reactos/files/ReactOS/0.4.14/ReactOS-0.4.14-iso.zip/download?use_mirror=netix"

ISO_ZIP_="${ISO_URL_%/*}"
ISO_ZIP_="${ISO_ZIP_##*/}"
# TODO: either use ${ISO_FILE} as the made up output filename,
#       or just calculat it from the `wget` output in some way:
wget -nv --show-progress -c --content-disposition ${ISO_URL_}
ls -l "${ISO_ZIP_}"
