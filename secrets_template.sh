#!/bin/bash

# Remove the encrypted secrets encoded file if it exists
rm -f ~/secrets_enc

# Git repository to clone
GIT_PRIVATE_REPO=""

# Path where the repository will be cloned
REPO_PATH=""

# Script to run after cloning the repository
POST_CLONE_SCRIPT=""

# List of known hosts
KNOWN_HOSTS[0]=""

clean_secrets() {
  # Clean variables
  unset GIT_PRIVATE_REPO
  unset KNOWN_HOSTS

  # Remove the secrets.sh file. This is important to avoid the secrets to be exposed
  rm -f ~/secrets.sh

  # Remove the clean_secrets function
  unset clean_secrets
}
