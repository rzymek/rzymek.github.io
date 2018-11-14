+++
date = "2018-01-04T21:02:12+01:00"
title = "Simplest Docker service"
draft = true

+++

# The Simplest Docker service

My first though when wanting to run a docker container as a system service, was to use `docker service`.
Like this

     docker service create --name nginx -p 80:80 \
        --mount type=bind,source=/var/www,destination=/usr/share/nginx/html \
        nginx

But this is sometimes an overkill. In case on `nginx` a much simpler solution would be

    docker run --detach --network host \
        --restart=always \
        -v /var/www:/usr/share/nginx/html:ro \
        nginx

For simple scenario the are a few benefits. It's the way to go, when you just what to have one instance on one specific host.

https://docs.docker.com/engine/reference/run/#restart-policies-restart