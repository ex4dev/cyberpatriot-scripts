#!/bin/bash
# Checks for common unwanted programs and asks if they should be removed.
echo -n "Enter name of package manager (apt/dnf): "
read pm
check_program () {
    echo -n "Do you need $1? (y/n): "
    read required
    if [ "$required" == "y" ] || [ "$required" == "Y" ]; then
        sudo $pm install $1 -y
    elif [ "$required" == "n" ] || [ "$required" == "N" ]; then
        sudo $pm remove $1 -y
    else
        check_program $1
    fi
}

# Servers
check_program "nginx"
check_program "apache2"
check_program "vsftpd"
check_program "sendmail"
check_program "openssh_server"
check_program "samba"
check_program "mysql*"
check_program "postgresql"
check_program "wordpress"

sudo $pm remove hydra hydra-gtk aircrack-ng fcrackzip lcrack ophcrack ophcrack-cli pdfcrack pyrit rarcrack sipcrack ipras zenmap nmap wireshark wireshark-common medusa deluge rfdump
sudo $pm autoremove -y

echo "Finished. This script only checks for common programs, there may be more that were not caught."
