+++
date = "2018-03-30"
subtitle = "Quick tip"
title = "Prevent docker from filling up your disk"

+++

Deploying docker container as part of your continuous integration can cause your disk to fill up pretty quick.
Docker does reuse the layers that did not change between deployments. But still, that last layer with you `.war` or `.js` bundle can take a few hundred megabytes.
Taking into account, that you should be deploying a new version of every update of the `master` branch, this can take up a gigabyte every day. And you don't really need all those old images and containers on your dev environment.

Docker, by itself, does not do any cleaning up. You need to tell it to. There is the command that [removes unused data](https://docs.docker.com/engine/reference/commandline/system_prune/):

    docker system prune
But still, you need to run it periodically by yourself. Also, you might want to keep those not-that-old container logs for debug purposes. 

## Automatic cleaning

The simplest, yet sufficient solution is to run this line daily:

    docker system prune -af  --filter "until=$((30*24))h"

The `-a` flag will remove all unused images not just dangling ones. The other one (`-f`) prevents the confirmation prompt. 
That's good, cause will be running this command from `cron`. Last flag (`--filter`) causes the procedure to spare the images and stopped containers from the last month. 

Docker, as it is written in [go](https://go-lang.org), parses time duration strings using [go's build in function](https://golang.org/pkg/time/#ParseDuration). The downside is that the longest unit is supports is `h` - hour. That's why we can't just pass *`until=30d`*.
We need to specify the number of hours. Writing `until=720h` does not obviously tell the next maintainer we meant a month. Still, we can use `bash`'s ability to do [basic math](http://tldp.org/LDP/abs/html/arithexp.html). At least the expression `30*24h` quickly hints we meant 30 days.  
Thus `--filter "until=$((30*24))h"`.

One last thing. Make the system run list line daily.

The `/etc/cron.daily` directory allows us to not even bother with [`cron` expressions](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm).
Just create a file `/etc/cron.daily/docker-prune`. Make is executable with

    chmod +x /etc/cron.daily/docker-prune

It's contents is just:

    #!/bin/bash
    docker system prune -af --filter "until=$((30*24))h"

### Optional logging
If you'd like to have some basic logging you can extend the script like this:

    #!/bin/bash
    log=/var/lib/docker/prune.log
    date +'=== %Y.%m.%d %H:%M ===' >> $log
    docker system prune -af --filter "until=$((30*24))h" >> $log

This will cause every execution to add a timestamp and docker's output to `/var/lib/docker/prune.log` file.