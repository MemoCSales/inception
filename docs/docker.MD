# Docker
## Docker images
A Dockerfile is a text file that container instructions to build a Docker image. Each line in the Dockerfile specifies a step in the image creation process.

## General Structure of a Dockerfile
1. Base image: Starts with `FROM` to specify the foundation of your image.
  - Example: `FROM ubuntu:20.04`

2. Copy/Build Dependencies:
  - Add files or install dependencies requires by your application
  - Examples:
      ```dockerfile
      RUN apt-get update && apt-get install -y curl
      COPY ./app /usr/src/app
      ```

3. Expose Ports:
  - Document the ports the container will listen on.
  - Example: `EXPOSE 8080`

4. Entry Command:
  - Use `CMD` or `ENTRYPOINT` to define the main process the container will run.
  - Example:
    ```dockerfile
    CMD ["python", "app.py"]
    ```

### Key Differences Between CMD and ENTRYPOINT
- CMD:
  - Used to provide default arguments to the container’s main process.
  - Can be overridden when running the container (docker run).

- ENTRYPOINT:
  - Used to define the executable that the container will always run.
  - Cannot be overridden but can accept additional arguments.

## Docker flags
### Commonly Used Docker Flags

1. `-d` or `--detach`:
  - Run container in background and print container ID.
  - Example: `docker run -d <image_name>`

2. `-p` or `--publish`:
  - Publish a container's port(s) to the host.
  - Example: `docker run -p <host_port>:<container_port> <image_name>`

3. `-it`:
  - Combine `-i` (interactive) and `-t` (pseudo-TTY) to run a container interactively.
  - Example: `docker run -it <image_name> /bin/bash`

4. `--name`:
  - Assign a name to the container.
  - Example: `docker run --name <container_name> <image_name>`

5. `-v` or `--volume`:
  - Bind mount a volume.
  - Example: `docker run -v <host_path>:<container_path> <image_name>`

6. `--rm`:
  - Automatically remove the container when it exits.
  - Example: `docker run --rm <image_name>`

7. `-e` or `--env`:
  - Set environment variables.
  - Example: `docker run -e MY_ENV_VAR=value <image_name>`

8. `--network`:
  - Connect a container to a network.
  - Example: `docker run --network <network_name> <image_name>`

9. `--restart`:
  - Define the restart policy for the container.
  - Example: `docker run --restart always <image_name>`

10. `-u` or `--user`:
  - Specify the user to run the container as.
  - Example: `docker run -u <username> <image_name>`

11. `-t` or `--tty`:
  - Allocate a pseudo-TTY.
  - Example: `docker run -t <image_name>`

## Docker commands

### Docker information
```sh
docker --version
docker info
```

### List all Docker containers (running and stopped)
`docker ps -a`

### List only running Docker containers
`docker ps`

### Start a Docker container
`docker start <container_id>`

### Stop a Docker container
`docker stop <container_id>`

### Remove a Docker container
`docker rm <container_id>`

### Remove all stopped containers
`docker container prune`

### List all Docker images
`docker images`

### Remove a Docker image
`docker rmi <image_id>`

### Build a Docker image from a Dockerfile
`docker build -t <image_name> .`

### Run a Docker container from an image
`docker run -d -p <host_port>:<container_port> <image_name>`

### Run a Docker container with an interactive terminal
`docker run -it <image_name> /bin/bash`

### Show logs from a Docker container
`docker logs <container_id>`

### Follow logs from a Docker container
`docker logs -f <container_id>`

### Execute a command in a running Docker container
`docker exec -it <container_id> <command>`

### Show Docker system information
`docker info`

### Show Docker version
`docker version`

### Remove all unused data (containers, images, networks, volumes)
`docker system prune -a`

## Use of docker TSL certificates

To achieve this, you need to set up Docker secrets to store confidential information, configure NGINX as the only entry point using port 443 with TLSv1.2 or TLSv1.3, and use Docker Compose to manage the services. Here are the steps:

1. **Create Docker Secrets:**

First, create the secrets you need. For example, let's create a secret for the TLS certificate and key.

```dockerfile
echo "your_tls_certificate_content" | docker secret create tls_cert -
echo "your_tls_key_content" | docker secret create tls_key -
```

2. **Create `docker-compose.yml` File:**

Create a `docker-compose.yml` file to define your services and networks.

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:latest
    ports:
      - "443:443"
    secrets:
      - tls_cert
      - tls_key
    volumes:
      - /etc/nginx/conf.d
    networks:
      - mynetwork
    deploy:
      placement:
        constraints: [node.role == manager]
    configs:
      - source: nginx_conf
        target: /etc/nginx/nginx.conf

networks:
  mynetwork:
    driver: bridge

secrets:
  tls_cert:
    external: true
  tls_key:
    external: true

configs:
  nginx_conf:
    file: ./nginx.conf
```
