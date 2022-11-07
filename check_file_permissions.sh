#!/bin/bash
# This script checks some important system files for permission issues and prints any problematic files.

# These files should not be writable or executable by anyone except root.
unwritable_only=("/etc/vsftpd.conf" "/etc/sudoers" "/etc/group" "/etc/passwd" "/etc/sshd_config", "/etc/hosts", "/etc/fstab")
# These files should not be readable, writable, or executable by anyone except root.
unreadable=("/etc/shadow", "/etc/shadow-", "/etc/gshadow", "/etc/gshadow-")


for file in ${unwritable_only[@]}; do
    fileinfo=$(ls -l $file) &&
    fileinfoarray=($fileinfo) &&
    if [ ${fileinfoarray[0]:8:2} != "--" ] || [ ${fileinfoarray[2]} != "root" ] || [ ${fileinfoarray[3]} != "root" ]; then
        echo $fileinfo
    fi
done
for file in ${unreadable[@]}; do
    fileinfo=$(ls -l $file) &&
    fileinfoarray=($fileinfo) &&
    if [ ${fileinfoarray[0]:7:3} != "---" ] || [ ${fileinfoarray[2]} != "root" ] || [ ${fileinfoarray[3]} != "root" ]; then
        echo $fileinfo
    fi
done
echo "Done."
