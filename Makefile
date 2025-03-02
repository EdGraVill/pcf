# Decrypt secrets file
SECRETS_TEMPLATE=./secrets_template.sh
SECRETS_FILE_ENC=./secrets_enc
SECRETS_FILE=./secrets.sh
PRIVATE_KEY_ENC=./id_rsa_enc
PRIVATE_KEY=./id_rsa
PUBLIC_KEY_ENC=./id_rsa.pub_enc
PUBLIC_KEY=./id_rsa.pub

define confirm_overwrite
	@# Check if file exists, if so prompt y/N to overwrite
	@if [ -f $(1) ]; then \
		read -p "$(2) already exists, overwrite? (y/N): " response; \
		if [ "$$response" != "y" ]; then \
			echo "Exiting..."; \
			exit 1; \
		fi; \
	fi
endef

define can_encrypt
	@# Check if file exists, if not don't do anything
	@if [ ! -f $(1) ]; then \
		echo "$(2) does not exist, nothing to encrypt"; \
		exit 1; \
	fi
endef

define run_encrypt
	@ENCRYPT_OUTPUT="$$(openssl enc -aes-256-cbc -salt -pbkdf2 -in $(1) -out $(2) 2>&1)"; \
	echo "$(3) encrypted successfully"
endef

define run_decrypt
	@DECRYPT_OUTPUT="$$(openssl enc -d -aes-256-cbc -salt -pbkdf2 -in $(1) -out $(2) 2>&1)"; \
	if [ "$$DECRYPT_OUTPUT" = "bad decrypt" ]; then \
		echo "Password incorrect, please try again"; \
		exit 1; \
	fi; \
	echo "$(3) decrypted successfully"
endef

encrypt-secrets:
	$(call can_encrypt,$(SECRETS_FILE),Secrets file)
	$(call run_encrypt,$(SECRETS_FILE),$(SECRETS_FILE_ENC),Secrets file)

decrypt-secrets:
	$(call confirm_overwrite,$(SECRETS_FILE),Secrets file)
	$(call run_decrypt,$(SECRETS_FILE_ENC),$(SECRETS_FILE),Secrets file)

encrypt-private-key:
	$(call can_encrypt,$(PRIVATE_KEY),Private key)
	$(call run_encrypt,$(PRIVATE_KEY),$(PRIVATE_KEY_ENC),Private key)

decrypt-private-key:
	$(call confirm_overwrite,$(PRIVATE_KEY),Private key)
	$(call run_decrypt,$(PRIVATE_KEY_ENC),$(PRIVATE_KEY),Private key)

encrypt-public-key:
	$(call can_encrypt,$(PUBLIC_KEY),Public key)
	$(call run_encrypt,$(PUBLIC_KEY),$(PUBLIC_KEY_ENC),Public key)

decrypt-public-key:
	$(call confirm_overwrite,$(PUBLIC_KEY),Public key)
	$(call run_decrypt,$(PUBLIC_KEY_ENC),$(PUBLIC_KEY),Public key)

generate-keys:
	$(call confirm_overwrite,$(PRIVATE_KEY),Private key)
	$(call confirm_overwrite,$(PUBLIC_KEY),Public key)
	@# Generate keys
	@read "Identity (user@domain): " IDENTITY; \
	ssh-keygen -t rsa -b 4096 -C "$$IDENTITY" -f $(PRIVATE_KEY) -N ""
	@echo "Keys generated successfully"

generate-secrets:
	$(call confirm_overwrite,$(SECRETS_FILE),Secrets file)
	@# If secrets.sh exists, delete it
	@rm -f $(SECRETS_FILE)
	@# Generate secrets file
	@cp $(SECRETS_TEMPLATE) $(SECRETS_FILE)
	@echo "Secrets file generated successfully"
