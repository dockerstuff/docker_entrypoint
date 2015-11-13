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

# Add a user here
USERNAME=$(${CWD}/config_user.sh)

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

