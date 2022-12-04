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
fi

# Change passwords
echo -n "Change the password of every user to a secure one? (y/N) "
read password_confirm
if [ "$password_confirm" == "y" ] || [ "$password_confirm" == "Y" ]; then
    current_users=($(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1 | tr "\n" " "))
    for user in ${current_users[@]}; do
        if [ "$user" == "$USER" ]; then
            echo "Skipping $user, the currently logged in user."
            continue
        fi
        echo "Changing password of $user"
        echo -e "^RNT*jHBntneFb%Ag4UGfB\n^RNT*jHBntneFb%Ag4UGfB" | sudo passwd $user
    done
fi

# Update password policies
echo -n "Update password policies? (y/N) "
read policy_confirm
if [ "$policy_confirm" == "y" ] || [ "$policy_confirm" == "Y" ]; then
    sed -i 's/PASS_MAX_DAYS.*$/PASS_MAX_DAYS 30/;s/PASS_MIN_DAYS.*$/PASS_MIN_DAYS 10/;s/PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs
    echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' >> /etc/pam.d/common-auth
    sudo apt install libpam-cracklib -y &&
    sed -i 's/\(pam_unix\.so.*\)$/\1 remember=5 minlen=8/' /etc/pam.d/common-password &&
    sed -i 's/\(pam_cracklib\.so.*\)$/\1 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
fi
echo "Done."
