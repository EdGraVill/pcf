# Decrypt secrets file
SECRETS_FILE_ENC=./secrets_enc
SECRETS_FILE=./secrets.sh
PRIVATE_KEY=./id_rsa
PRIVATE_KEY_ENC=./id_rsa_enc
PUBLIC_KEY=./id_rsa.pub
PUBLIC_KEY_ENC=./id_rsa.pub_enc

decrypt-secrets:
	@# Check if secrets file exists, if so prompt y/N to overwrite
	@if [ -f $(SECRETS_FILE) ]; then \
		read -p "Secrets file already exists, overwrite? (y/N): " response; \
		if [ "$$response" != "y" ]; then \
			echo "Exiting..."; \
			exit 1; \
		fi; \
	fi
	@# Decrypt secrets file
	@DECRYPT_OUTPUT="$$(openssl enc -d -aes-256-cbc -salt -pbkdf2 -in $(SECRETS_FILE_ENC) -out $(SECRETS_FILE) 2>&1)"
	@# If password invalid, remove secrets file and run again
	@if [ "$$DECRYPT_OUTPUT" == "bad decrypt" ]; then \
		echo "Password incorrect, please try again"; \
		exit 1; \
	fi
	@echo "Secrets file decrypted successfully"

encrypt-secrets:
	@# Check if secrets file exists, if not don't do anything
	@if [ ! -f $(SECRETS_FILE) ]; then \
		echo "Secrets file does not exist, nothing to encrypt"; \
		exit 1; \
	fi
	@# Encrypt secrets file
	@ENCRYPT_OUTPUT="$$(openssl enc -aes-256-cbc -salt -pbkdf2 -in $(SECRETS_FILE) -out $(SECRETS_FILE_ENC) 2>&1)"
	@echo "Secrets file encrypted successfully"

decrypt-private-key:
	@# Check if private key exists, if so prompt y/N to overwrite
	@if [ -f $(PRIVATE_KEY) ]; then \
		read -p "Private key already exists, overwrite? (y/N): " response; \
		if [ "$$response" != "y" ]; then \
			echo "Exiting..."; \
			exit 1; \
		fi; \
	fi
	@# Decrypt private key
	@DECRYPT_OUTPUT="$$(openssl enc -d -aes-256-cbc -salt -pbkdf2 -in $(PRIVATE_KEY_ENC) -out $(PRIVATE_KEY) 2>&1)"
	@# If password invalid, remove private key and run again
	@if [ "$$DECRYPT_OUTPUT" == "bad decrypt" ]; then \
		echo "Password incorrect, please try again"; \
		exit 1; \
	fi
	@echo "Private key decrypted successfully"

encrypt-private-key:
	@# Check if private key exists, if not don't do anything
	@if [ ! -f $(PRIVATE_KEY) ]; then \
		echo "Private key does not exist, nothing to encrypt"; \
		exit 1; \
	fi
	@# Encrypt private key
	@ENCRYPT_OUTPUT="$$(openssl enc -aes-256-cbc -salt -pbkdf2 -in $(PRIVATE_KEY) -out $(PRIVATE_KEY_ENC) 2>&1)"
	@echo "Private key encrypted successfully"

decrypt-public-key:
	@# Check if public key exists, if so prompt y/N to overwrite
	@if [ -f $(PUBLIC_KEY) ]; then \
		read -p "Public key already exists, overwrite? (y/N): " response; \
		if [ "$$response" != "y" ]; then \
			echo "Exiting..."; \
			exit 1; \
		fi; \
	fi
	@# Decrypt public key
	@DECRYPT_OUTPUT="$$(openssl enc -d -aes-256-cbc -salt -pbkdf2 -in $(PUBLIC_KEY_ENC) -out $(PUBLIC_KEY) 2>&1)"
	@# If password invalid, remove public key and run again
	@if [ "$$DECRYPT_OUTPUT" == "bad decrypt" ]; then \
		echo "Password incorrect, please try again"; \
		exit 1; \
	fi
	@echo "Public key decrypted successfully"

encrypt-public-key:
	@# Check if public key exists, if not don't do anything
	@if [ ! -f $(PUBLIC_KEY) ]; then \
		echo "Public key does not exist, nothing to encrypt"; \
		exit 1; \
	fi
	@# Encrypt public key
	@ENCRYPT_OUTPUT="$$(openssl enc -aes-256-cbc -salt -pbkdf2 -in $(PUBLIC_KEY) -out $(PUBLIC_KEY_ENC) 2>&1)"
	@echo "Public key encrypted successfully"
