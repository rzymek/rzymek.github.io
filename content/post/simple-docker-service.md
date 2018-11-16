---
date: "2018-11-16"
title: "Simplest Docker service"
tags: ['docker']
---

# The Simplest Docker service

My first thought when wanting to run a docker container as a system service, was to use `docker service`.
Like this

     docker service create --name nginx -p 80:80 \
        --mount type=bind,source=/var/www,destination=/usr/share/nginx/html \
        nginx

But this is sometimes an overkill. In case on `nginx` a much simpler solution would be

    docker run --detach --network host \
        --restart=always \
        -v /var/www:/usr/share/nginx/html:ro \
        nginx

It's the way to go, when you just what to have one instance on one specific host.
The container will be started after **system reboot** - it will always
start on docker daemon startup.  
Just remember to enable docker on system boot with:

    systemctl enable docker
