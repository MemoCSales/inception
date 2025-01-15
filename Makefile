NAME = inception

# Variables
VM_USER = mcruz-sa
VM_HOST = localhost
VM_PORT = 4242
PROJECT_DIR = $(shell pwd)
REMOTE_DIR = /home/$(VM_USER)/$(NAME)

# Docker rules


# VM rules
vm-start:
	VBoxManage startvm "inception" --type headless

vm-stop:
	VBoxManage controlvm "inception" acpipowerbutton

vm-status:
	VBoxManage showvminfo "inception"

# Sync rules
sync:
	rsync -avz --progress --stats -e "ssh -p $(VM_PORT)" \
	$(PROJECT_DIR)/ $(VM_USER)@$(VM_HOST):$(REMOTE_DIR)/ \
	--exclude='.git/' \
	--exclude='*.log'

sync-delete:
	rsync -avz --delete --progress --stats -e "ssh -p $(VM_PORT)" \
	$(PROJECT_DIR)/ $(VM_USER)@$(VM_HOST):$(REMOTE_DIR)/ \
	--exclude='.git/' \
	--exclude='*.log'

verify-sync:
	rsync -avzn -e "ssh -p $(VM_PORT)" \
	$(PROJECT_DIR)/ $(VM_USER)@$(VM_HOST):$(REMOTE_DIR)/

.PHONY: vm-start vm-stop vm-status sync sync-delete verify-sync
