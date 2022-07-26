# Template for running docker with laravel

## Software version
* php-fpm docker base image: php:7.4-fpm
* Laravel version: 8.40
* Mysql: 5.7
* composer: latest version
* docker-compose: version 1.29.1

## How to build base
```
make build_base
```

## How to run application on local

```
make build_php

# Run all component
make up

# Don't care about base and nodejs service. It can be stopped when you check status of all containers
make show_all
```

## How to access the service
```
# Visit http://localhost:20001
# Visit healthcheck to check the access log - http://0.0.0.0:20001/healthcheck
# Visit phpmysqladmin - http://0.0.0.0:20002 (host: mysql, username: root, password: 123456)
```

## How to destroy all resources
```
make down
```

## How to check log php and nginx
### Php log (Ctrl + C to exit the terminal)
```
make log_php
```
### Nginx log (Ctrl + C to exit the terminal)
```
make log_nginx
```

## How to access php and run commandlines (Type exit to out of the container)
```
make access_php
composer install
php artisan migrate
```

## Laravel session and cache
```
make access_php
php artisan cache:table
php artisan session:table
php artisan migrate
```

## Add css and js by running node
```
docker-compose -p laraveldemo -f docker-compose.yml up node
```

### Upgradet laravel (Please backup your source before doing that)
```
rm -rf src && mkdir src
DOCKER_IMAGE=laraveldemo_base
docker run -i --rm \
    --entrypoint '/bin/bash' \
    -v ${PWD}/src:/app ${DOCKER_IMAGE} \
    -c 'composer create-project laravel/laravel /app'
```
### How to improve it when running on production
```
- Add remove healthcheck nginx log
- Remove healthcheck applicaton log

```