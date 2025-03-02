# Public Configuration Files

This repository contains the files to clone a private repository from this public via curl. To achieve that, you need to follow the steps below:

## Instructions

1. Fork this repository (From now on, known as "public repository")
2. Clone this repository to your local machine
3. Create a private repository with all the scripts and files you need
4. Execute `make generate-keys` to generate the SSH keys
5. Execute `make encrypt-private-key` to encrypt the private key and make it available to the public repository
6. Execute `make encrypt-public-key` to encrypt the public key and make it available to the public repository
7. Add the public key to your private repository
8. Execute `make generate-secrets` to generate the secrets file
9. In the "secrets.sh" file, replace the
   1. `REPOSITORY_URL` variable with the URL of your private repository
   2. `REPO_PATH` variable with the path of where you want to clone the repository
   3. `POST_CLONE_SCRIPT` variable with the path of the script you want to execute after cloning the repository (Relative to the repository root)
   4. `KNOWN_HOSTS[@]` array with the known hosts of your private repository
10. In the "init.sh" file, replace the `FILES_URL` variable with the URL of the public repository
11. Execute `make encrypt-secrets` to encrypt the secrets file and make it available to the public repository
12. Push the changes to the public repository
13. Now this files are available in the public repository. You can run something like `bash -c "$(curl -fsSL https://raw.githubusercontent.com/EdGraVill/pcf/refs/heads/main/init.sh)"` and it will do all the magic for you.

## Steps

`init.sh` is meant to be run in a fresh environment. It will clone a private repository and the execute a script that you specify. The script will be executed in the repository root.

`init.sh` will:
1. Prompt user if they want to start
2. Check if the OS is supported
3. Check if git is installed, if not, install it
4. Check if openssl is installed, if not, install it
5. Check if ssh-keygen is installed, if not, install it
6. Fetch the secrets file
7. Ask for the encryption password
8. Decrypt the secrets file
9. Source the secrets file
10. Fetch RSA keypair
11. Decrypt the keypair
12. Add the private key to the ssh-agent
13. Clone the private repository
14. Run the post clone script file
