#!/bin/bash
# This script compares the list of users on the computer with the list of authorized users, and automatically deletes unauthorized users from the computer.
echo "Enter the usernames of all authorized non-administrators, with a space in between each one."
read -a allowed_standard_users
echo "Enter the usernames of all authorized administrators, with a space in between each one."
read -a allowed_administrators
echo "Enter the name of the admin group (usually admin on ubuntu and wheel on fedora)"
read admin_group
current_users=($(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1 | tr "\n" " "))

# Check for unauthorized users
users_to_delete=()
echo "The following users are not allowed on the system."
for user in ${current_users[@]}; do
    if [[ ! " ${allowed_standard_users[*]} " =~ " $user " ]] && [[ ! " ${allowed_administrators[*]} " =~ " $user " ]]; then
        echo $user
        users_to_delete+=$user
    fi
done
echo -n "Delete these users? (y/N) "
read delete_confirm
if [ "$delete_confirm" == "y" ] || [ "$delete_confirm" == "Y" ]; then
    for user in ${users_to_delete[@]}; do
        sudo userdel $user > /dev/null
    done
    echo "Done."
fi
# Check for unauthorized administrators
current_administrators=($(getent group $admin_group | cut -d : -f 4 | tr "," " "))
users_to_demote=()
echo "The following users have administrative access when they are not supposed to."
for user in ${current_administrators[@]}; do
    if [[ ! " ${allowed_administrators[*]} " =~ " $user " ]]; then
        echo $user
        users_to_demote+=$user
    fi
done
echo -n "Remove administrative access from these users? (y/N) "
read demote_confirm
if [ "$demote_confirm" == "y" ] || [ "$demote_confirm" == "Y" ]; then
    for user in ${users_to_demote[@]}; do
        sudo gpasswd -d $user $admin_group > /dev/null
    done
    echo "Done."
fi

