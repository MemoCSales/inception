NAME = inception

# Variables
VM_USER = mcruz-sa
VM_HOST = localhost
VM_PORT = 4242
PROJECT_DIR = $(shell pwd)
REMOTE_DIR = /home/$(VM_USER)/$(NAME)
WP_DATA = /home/data/wordpress
DB_DATA = /home/data/mariadb

# Docker cleanup commands
DOCKER_STOP = docker stop
DOCKER_RM = docker rm
DOCKER_RMI = docker rmi -f
DOCKER_VOLUME_RM = docker volume rm
DOCKER_NETWORK_RM = docker network rm

# Docker resource lists
CONTAINERS = $(shell docker ps -aq)
IMAGES = $(shell docker images -q)
VOLUMES = $(shell docker volume ls -q)
NETWORKS = $(shell docker network ls --filter "name=inception" -q)

# Docker rules
up:
	docker-compose -f srcs/docker-compose.yml up -d

stop:
	docker-compose -f srcs/docker-compose.yml stop

down:
	docker-compose -f srcs/docker-compose.yml down

build:
	docker-compose -f srcs/docker-compose.yml build

rebuild:
	docker-compose -f srcs/docker-compose.yml up -d --build

restart:
	docker-compose -f srcs/docker-compose.yml restart

ps:
	@echo "Running containers:"
	@docker ps -a

images:
	@echo "Docker Images:"
	@docker images

volumes:
	@echo "Docker Volumes:"
	@docker volume ls

status: ps images volumes
	@echo "\nNetworks:"
	@docker network ls

clean:
	@if [ -n "$(CONTAINERS)" ]; then $(DOCKER_STOP) $(CONTAINERS); fi
	@if [ -n "$(CONTAINERS)" ]; then $(DOCKER_RM) $(CONTAINERS); fi
	@if [ -n "$(IMAGES)" ]; then $(DOCKER_RMI) $(IMAGES); fi
	@if [ -n "$(VOLUMES)" ]; then $(DOCKER_VOLUME_RM) $(VOLUMES); fi
	@if [ -n "$(NETWORKS)" ]; then $(DOCKER_NETWORK_RM) $(NETWORKS); fi
	@rm -rf $(WP_DATA) $(DB_DATA) || true

prune: clean
	@docker system prune -a --volumes -f

re: clean up

# MariaDB

maria:
	docker exec -it mariadb mysql -u root -p

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
git:
	git add .
	git commit -m "$(message)"
	git push

# SSH rules
ssh:
	 ssh -p $(VM_PORT) $(VM_USER)@$(VM_HOST)

.PHONY: up stop down restart build rebuild restart ps images volumes status clean re prune vm-start vm-stop vm-status copy verify-copy git ssh
