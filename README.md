# Docker Commons
Common script/settings for docker containers.

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

[]
Carlos
