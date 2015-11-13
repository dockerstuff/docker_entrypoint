#!/bin/bash -e
#==============================================#
# Script to support the initialization process #
#  in a docker container.                      #
#==============================================#

# Executable to which cl arguments should fit
INTERP="${ENTRYPOINT-'echo'}"

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
    # Variables DUSER, DUID, DGID are read from the  #
    #  environment; if NOUSER is set, do nothing.    #
    #================================================#
    
    DEFAULT_USER="user"
    DEFAULT_UID="1000"
    DEFAULT_GID="100"
    
    [[ ! -z "$NOUSER" ]] && \
        # nothing to be done here
        return 0
    
    DUSER="${DUSER-$DEFAULT_USER}"
    DUID="${DUID-$DEFAULT_UID}"
    DGID="${DGID-$DEFAULT_GID}"
    
    useradd -u "$DUID" \
            -g "$DGID" \
            -d "/home/$DUSER" -m \
            -s /bin/bash \
            "$DUSER"
    
    echo $DUSER
}


# Add a user here
USERNAME=$(config_user)

# If no user created, define the current one (root)
[[ `id $USERNAME` ]] || USERNAME="$USER"

# Garantee the user will run on a proper place.
# WORKDIR is the dir where the user will run from.
if [ ! -z "$WORKDIR" ]; then
    # If WORKDIR is defined, verify the permissions
    if [ -d "$WORKDIR" ]; then
        if [ ! -w "$WORKDIR" ]; then
            chown -R ${USERNAME}: $WORKDIR
            chmod 755 $WORKDIR
        fi
    else
        mkdir -p $WORKDIR
        chown ${USERNAME}: $WORKDIR
    fi
else
    # If WORKDIR is not defined, use its HOME
    WORKDIR=$(getent passwd $USERNAME | awk -F: '{print $(NF-1)}')
fi

su -l $USERNAME -c "cd $WORKDIR && $INTERP $DARGS"

#!/bin/bash -e

