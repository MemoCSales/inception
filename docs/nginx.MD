# NGINX Documentation

## Understanding NGINX by creating a Docker image

NGINX is a high-performance HTTP server, reverse proxy, and load balancer. It is widely used for its stability, rich feature set, simple configuration, and low resource consumption.

### Overview of NGINX

NGINX can be used to serve static content, handle dynamic content by acting as a reverse proxy, and manage load balancing for multiple backend servers. It is highly scalable and can handle a large number of concurrent connections.

### Using NGINX with Docker for Inception Project

For your Inception project at 42 school, you need to use NGINX with Docker. This involves creating a Docker image for NGINX and configuring it using `docker-compose.yml`.

### Steps to Create and Use NGINX Docker Image

1. **Create a Dockerfile**: Define the NGINX image.
	```Dockerfile
	##from which image we will deploy out container
	FROM alpine:3.19
	##Next what software and how we want to install inside the container
	##the apk file manager updates its lists and searches the latest versions of software, then update the outdated packages and install nginx without saving srcs in the cache.
	RUN	apk update && apk upgrade && apk add --no-cache nginx
	##open the  port through which the container will exchange traffic
	EXPOSE 443
	##run the installed configuration
	##Using "daemon off" we run nginx directly and not in daemon mode.
	CMD ["nginx", "-g", "daemon off;"]
	```

2. **Create a `docker-compose.yml` file**: Define the services.
	```yaml
	version: '3'

	services:
	  nginx:
		build: .
		ports:
		  - "80:80"
		volumes:
		  - ./nginx.conf:/etc/nginx/nginx.conf
	```

3. **Run Docker Compose**: Build and start the NGINX container.
	```sh
	docker-compose up --build
	```

### Customizing NGINX Configuration

You can customize the NGINX configuration by editing the `nginx.conf` file. This file allows you to define server blocks, set up reverse proxies, and configure load balancing.

### Example `nginx.conf`

```nginx
events { }

http {
	server {
		listen 80;
		server_name localhost;

		location / {
			root /usr/share/nginx/html;
			index index.html index.htm;
		}
	}
}
```

By following these steps, you can set up and use NGINX with Docker for your Inception project, meeting the requirements of using `docker-compose.yml`.

