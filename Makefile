NAME = inception

# Variables
VM_USER = mcruz-sa
VM_HOST = localhost
VM_PORT = 4242
PROJECT_DIR = $(shell pwd)
REMOTE_DIR = /home/$(VM_USER)/$(NAME)

# Docker rules
up:
	docker-compose -f srcs/docker-compose.yml up -d

down:
	docker-compose -f srcs/docker-compose.yml down

restart:
	docker-compose -f srcs/docker-compose.yml restart

clean:
	docker-compose -f srcs/docker-compose.yml down -v
	docker system prune -af

# VM rules
vm-start:
	VBoxManage startvm "inception" --type headless

vm-stop:
	@echo "Initiating safe shutdown..."
	VBoxManage controlvm "inception" acpipowerbutton
	@echo "Waiting for VM to shutdown gracefully..."
	@sleep 10
	@if VBoxManage showvminfo "inception" | grep -q "running"; then \
		echo "VM still running, forcing shutdown..."; \
		VBoxManage controlvm "inception" poweroff; \
	else \
		echo "VM shutdown completed successfully"; \
	fi

vm-status:
	VBoxManage showvminfo "inception"

# Copy rules
copy:
	@echo "Creating remote directory if it doesn't exist..."
	@ssh -p $(VM_PORT) $(VM_USER)@$(VM_HOST) "mkdir -p $(REMOTE_DIR)"
	@echo "Copying files to VM..."
	@scp -r -P $(VM_PORT) \
	srcs \
	Makefile \
	README.md \
	$(VM_USER)@$(VM_HOST):$(REMOTE_DIR)/

verify:
	ssh -p $(VM_PORT) $(VM_USER)@$(VM_HOST) "ls -la $(REMOTE_DIR)"


# Git rules
gitp:
	git add .
	git commit -m "$(message)"
	git push

.PHONY: up down restart clean vm-start vm-stop vm-status copy verify-copy gitp
