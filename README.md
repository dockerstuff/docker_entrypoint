# Docker Entrypoint
Simple setup of Docker containers during initialization.

If you are reading this, chances are you know Docker and have been playing around with it. If that is the case, I can skip the introductions about containers -- which I will anyways -- and go straight to the point. 

We know containers are awesome, and also that they are _not_ exactly designed to offer dynamic environment. For instance, if one doesn't want to run the container as _root_, (s)he will have to setup a user during `docker-build`. If your container is meant to run a standalone service that's fine, but if you use containers like me, interactively, and containers became your standard testing environment for every new tool, then a bit of dynamism during initialization sounds good, right?

And that's why I wrote this `entrypoint.sh` script, to have some automation during container's initialization. Basically, I want to have the possibility of decide my user credentials during container's call, and have an adequate (container) environment for that. It understands and act accordingly to the following environment variables:

* `DOCKER_USER`: defines the name of user (default is '`user`')
* `DOCKER_UID`: defines the user UID (default is '`1000`')
* `DOCKER_GID`: defines the user's group GID (default is '`100`')
* `NOUSER`: run the container as _root_
* `WORKDIR`: set a work directory (default is '`/work`')
* `EXECAPP`: set the executable/app to run (default is '`/bin/bash`')

The `entrypoint.sh` script is meant to be used as a container's `ENTRYPOINT`.

## How to use it

### With Git
Put at the end of your `Dockerfile`:
```
RUN git clone -b stable https://github.com/chbrandt/docker_entrypoint.git && \
    ln -sf docker_entrypoint/entrypoint.sh /.

ENTRYPOINT ["/entrypoint.sh"]
```

### With Curl
Put at the end of your `Dockerfile`:
```
RUN curl -O https://raw.githubusercontent.com/chbrandt/docker_entrypoint/stable/entrypoint.sh && \
    chmod a+x docker_entrypoint/entrypoint.sh && \
    ln -sf docker_entrypoint/entrypoint.sh /.

ENTRYPOINT ["/entrypoint.sh"]
```


## Entrypoint
`entrypoint.sh` setup a [user](#user-setup) and a work directory with the proper permissions.
If the image where `entrypoint.sh` is being used has a `EXECAPP` defined, the
`entrypoint.sh` executes `EXECAPP` by the requested user, at `WORKDIR` using
the positional arguments given through `docker run` command.

### user setup
When running the `docker run` command, the user can specify a user name, uid and gid through
the variables `DOCKER_USER`, `DOCKER_UID`, `DOCKER_GID`, respectively.

For example:
```
# docker run -it -e DOCKER_USER='brandt' -e DOCKER_UID=500 -e DOCKER_GID=100 chbrandt/heasoft
```
This will run the image `chbrandt/heasoft` (which uses `entrypoint.sh`) as user `brandt`, that
has `uid=500` and `gid=100`.

/.\
