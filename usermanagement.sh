#!/bin/bash

# Check if the script is run as root or sudo user
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or sudo user"
  exit 1
fi

# Function to add a user
add_user() {
  read -p "Enter username: " username
  read -p "Enter full name: " full_name
  read -s -p "Enter password: " password
  echo
  read -s -p "Confirm password: " password_confirm
  echo

  if [ "$password" != "$password_confirm" ]; then
    echo "Passwords do not match"
    exit 1
  fi

  useradd -m -c "$full_name" "$username"
  echo "$username:$password" | chpasswd

  if [ $? -eq 0 ]; then
    echo "User $username has been added to system!"
  else
    echo "Failed to add a user!"
  fi
}

# Function to delete a user
delete_user() {
  read -p "Enter username: " username

  userdel -r "$username"

  if [ $? -eq 0 ]; then
    echo "User $username has been deleted from system!"
  else
    echo "Failed to delete the user!"
  fi
}

# Function to list users
list_users() {
  awk -F: '{ print $1}' /etc/passwd
}

# Function to change a user's password
change_password() {
  read -p "Enter username: " username

  if id "$username" &>/dev/null; then
    read -s -p "Enter new password: " password
    echo
    read -s -p "Confirm new password: " password_confirm
    echo

    if [ "$password" != "$password_confirm" ]; then
      echo "Passwords do not match"
      exit 1
    fi

    echo "$username:$password" | chpasswd

    if [ $? -eq 0 ]; then
      echo "Password for $username has been changed!"
    else
      echo "Failed to change the password!"
    fi
  else
    echo "User $username does not exist!"
  fi
}

# Main menu
while true; do
  echo "====================="
  echo " User Management Menu"
  echo "====================="
  echo "1. Add User"
  echo "2. Delete User"
  echo "3. List Users"
  echo "4. Change User Password"
  echo "5. Exit"
  read -p "Choose an option [1-5]: " option

  case $option in
    1)
      add_user
      ;;
    2)
      delete_user
      ;;
    3)
      list_users
      ;;
    4)
      change_password
      ;;
    5)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option, please try again."
      ;;
  esac
done

