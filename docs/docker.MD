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

```sh
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
