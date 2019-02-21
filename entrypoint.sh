#!/bin/bash -e
#==============================================#
# Script to support the initialization process #
#  in a docker container.                      #
#==============================================#
#set -xv

# Executable to which cl arguments should fit
_SHELL='/bin/bash'
EXECAPP="${EXECAPP:-$_SHELL}"

# Save the input cl arguments
DARGS="$*"

# Save the current path
CWD="$PWD"

function config_user()
{
    #================================================#
    # Config a User                                  #
    # -------------                                  #
    # It is meant to run during container's init     #
    #  process. Such process is necessary to better  #
    #  exchange files/bus between host/container.    #
    # Variables DOCKER_USER, DOCKER_UID, DOCKER_GID  #
    #  are read from the environment;                #
    #  if NOUSER is set, do nothing.                 #
    #================================================#

    DEFAULT_USER="user"
    DEFAULT_UID="1000"
    DEFAULT_GID="100"

    [[ -n "$NOUSER" ]] && \
        return 0       # nothing to be done here

    DOCKER_USER="${DOCKER_USER:-$DEFAULT_USER}"
    DOCKER_UID="${DOCKER_UID:-$DEFAULT_UID}"
    DOCKER_GID="${DOCKER_GID:-$DEFAULT_GID}"

    id $DOCKER_USER &> /dev/null || useradd -u "$DOCKER_UID" \
                                            -g "$DOCKER_GID" \
                                            -d "/home/$DOCKER_USER" -m \
                                            -s /bin/bash \
                                            "$DOCKER_USER"

    echo "$DOCKER_USER"
    return 0
}


# Add a user here
USERNAME=$(config_user)

# If no user created, use the current one (root by default)
id "$USERNAME" 2> /dev/null || USERNAME="$USER"

# Garantee the user will run on a proper place.
# WORKDIR is the dir where the user will run from.
[[ -z "$WORKDIR" ]] && export WORKDIR='/work'

# Verify WORKDIR existence
[[ ! -d "$WORKDIR" ]] && mkdir -p $WORKDIR

# And grant permissions
# To simplify the permissions now, I'll give ownership.
#TODO: give 'w/r/x' permissions instead of changing ownership;
#      this is important 'cause WORKDIR could already exist.
chown ${USERNAME}: $WORKDIR && chmod -R u+wrx $WORKDIR
USERID=$(id -u $USERNAME)
GROUPID=$(id -g $USERNAME)

echo ""
echo "#====================================================#"
echo " This container is running: $EXECAPP"
echo " with arguments: $DARGS"
echo ""
echo " by user: '${USERNAME} (uid:$USERID,gid:$GROUPID)'."
echo "#====================================================#"
echo ""

if [ "$EXECAPP" != "$_SHELL" ]; then
    su -l $USERNAME -c "cd $WORKDIR && $EXECAPP $DARGS"
else
    if [ -z "$DARGS" ]; then
        #cd $WORKDIR && su $USERNAME
        su -l $USERNAME
    else
        if [[ "$DARGS" == "--help" || "$DARGS" == "-h" && -f "/README.txt" ]]; then
            cat /README.txt
        else
          su -l $USERNAME -c "cd $WORKDIR && $DARGS"
        fi
    fi
fi
