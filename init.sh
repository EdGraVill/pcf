#!/bin/bash

# Check which OS are we running on, and store in the variable OS.
OS=$(uname -s)

# If OS is Linux, replace OS with the name of the distribution.
if [ "$OS" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    fi
fi

# If OS is macOS, replace OS with "macOS".
if [ "$OS" = "Darwin" ]; then
    OS="macOS"
fi

echo "Working on $OS"

# List of supportes OS
SUPPORTED_OS[0]="macOS"
SUPPORTED_OS[1]="Ubuntu"
SUPPORTED_OS[2]="Debian"

# Check if the OS is supported.
if [[ ! " ${SUPPORTED_OS[@]} " =~ " ${OS} " ]]; then
    echo "Unsupported OS: $OS"
    exit 1
fi

# Check if Git is installed. If not, install it
case $OS in
"macOS")
    GIT_OUTPUT=$(git --version 2>&1)
    if echo "$GIT_OUTPUT" | grep -q "No developer tools were found"; then
        echo "Git is not installed properly. If the Developer Tools installer prompt is not shown, please install it manually with 'xcode-select --install'"
        exit 1
    fi
    ;;
"Ubuntu" | "Debian")
    if ! command -v git &>/dev/null; then
        echo "Git is not installed. Installing Git using apt"
        sudo apt update
        sudo apt install -y git
    fi
    ;;
esac

# Check if openssl is installed. If not, install it
case $OS in
"macOS")
    if ! command -v openssl &>/dev/null; then
        echo "ERROR: Weird, OpenSSL should be installed by default on macOS"
        exit 1
    fi
    ;;
"Ubuntu" | "Debian")
    if ! command -v openssl &>/dev/null; then
        echo "OpenSSL is not installed. Installing OpenSSL using apt"
        sudo apt update
        sudo apt install -y openssl
    fi
    ;;
esac

# Check if ssh-keygen is installed. If not, install it
case $OS in
"macOS")
    if ! command -v ssh-keygen &>/dev/null; then
        echo "ERROR: Weird, ssh-keygen should be installed by default on macOS"
        exit 1
    fi
    ;;
"Ubuntu" | "Debian")
    if ! command -v ssh-keygen &>/dev/null; then
        echo "ssh-keygen is not installed. Installing ssh-keygen using apt"
        sudo apt update
        sudo apt install -y openssh-client
    fi
    ;;
esac

# Check if .ssh directory exists. If not, create it.
if [ ! -d ~/.ssh ]; then
    mkdir ~/.ssh

    # Copy encrypted ssh key to ~/.ssh directory
    # Since repo has not be cloned yet, fetch the encrypted ssh using curl
    curl -s -o ~/.ssh/id_rsa_enc -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/EdGraVill/pcf/refs/heads/main/id_rsa_enc

    # Prompt the user for the password, and store it in the variable PASSWORD.
    echo -n "Please enter your password: "
    read -s PASSWORD

    # Change directory to ~/.ssh
    pushd ~/.ssh

    # Decrypt the ssh key
    DECRYPT_OUTPUT=$(openssl enc -d -aes-256-cbc -salt -pbkdf2 -k "$PASSWORD" -in id_rsa_enc -out id_rsa 2>&1)

    # Check if the password is correct
    if echo "$DECRYPT_OUTPUT" | grep -q "bad decrypt"; then
        echo "ERROR: Incorrect password"
        exit 1
    fi

    # Remove the encrypted ssh key
    rm id_rsa_enc

    # Change the permissions of the ssh key
    chmod 400 id_rsa

    # Generate the public key
    ssh-keygen -y -f id_rsa >id_rsa.pub

    # Check if ssh-agent is running. If not, start it.
    if [ -z "$SSH_AGENT_PID" ]; then
        eval $(ssh-agent -s)
    fi

    # Add the ssh key to the ssh-agent
    ssh-add ./id_rsa

    # Change directory back to the original directory
    popd
fi

# Clone config repo
git clone git@github.com:EdGraVill/cf.git

# Continue from there
echo "All public stuff done. Now we can continue with the private stuff."
~/cf/continue.sh
