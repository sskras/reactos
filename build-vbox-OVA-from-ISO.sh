#!/bin/bash

ISO_URL_="https://sourceforge.net/projects/reactos/files/ReactOS/0.4.14/ReactOS-0.4.14-iso.zip/download?use_mirror=netix"

wget -nv --show-progress -c --content-disposition ${ISO_URL_}
