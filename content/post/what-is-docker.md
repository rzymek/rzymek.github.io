+++
date = "2018-01-03T23:06:14+01:00"
title = "What's so special about docker?"

+++

# What's so special about docker?

There are [quite](https://www.docker.com/what-container#/virtual_machines)
[a few](https://stackoverflow.com/questions/16047306/how-is-docker-different-from-a-normal-virtual-machine) 
[comparisons](https://www.sdxcentral.com/cloud/containers/definitions/what-is-docker-container-open-source-project/)
between docker containers and virtual machines on the interwebs.
That's exactly what made it more difficult for me to understand what containers actually are.
Then I came across the thought that docker is like [`chroot` on steroids]
(https://blog.jayway.com/2015/03/21/a-not-very-short-introduction-to-docker/). That's it! It's just an isolated process.
Not only on the filesystem level, but also all other resources like network and processes.

Check this out

    $ docker run --detach --name nginx nginx:alpine

Then on the host run

    $ ps -ef |grep [n]ginx
    root      8617  8593  0 23:22 ?        00:00:00 nginx: master process nginx -g daemon off;
    systemd+  8667  8617  0 23:22 ?        00:00:00 nginx: worker process

You can see the processes from inside the container on the host. They's are children of the docker daemon process:

    $ pstree `pidof dockerd`
    dockerd─┬─docker-containe─┬─docker-containe─┬─nginx───nginx
            │                 │                 └─7*[{docker-containe}]
            │                 └─12*[{docker-containe}]
            └─13*[{dockerd}]


Obviously you can't see it the over way around.
This list of processes visible from inside the container is very short:

    $ docker exec nginx ps -ef
    PID   USER     TIME   COMMAND
    1 root       0:00 nginx: master process nginx -g daemon off;
    6 nginx      0:00 nginx: worker process
    7 root       0:00 ps -ef

## It's an old idea actually...

`chroot` dates back to [1979](https://en.wikipedia.org/wiki/Chroot#History). Linux containers (LXC) - the technology Docker uses under the hood - were available in kernel as early as [2.6.24](https://en.wikipedia.org/wiki/LXC#Overview) which was released back in 2008. So why all the fuss about containers now? Just look at Stack Overflow's [docker tag trends](https://insights.stackoverflow.com/trends?tags=docker):  
![](/img/docker-tag-trend.svg)  
The interest kinda exploded right from the start, when it [debuted at PyCon in 2013](https://en.wikipedia.org/wiki/Docker_\(software\)#History).  
It all comes down to one thing - **tooling**. Docker provides great tools for developers. Tools for building images, running them, configuring, controlling and quite importantly distributing. That really brought the container technology to the people.

