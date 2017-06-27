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
    # Variables DUSER, DUID, DGID are read from the  #
    #  environment; if NOUSER is set, do nothing.    #
    #================================================#
    
    DEFAULT_USER="user"
    DEFAULT_UID="1000"
    DEFAULT_GID="100"
    
    [[ ! -z "$NOUSER" ]] && \
        # nothing to be done here
        return 0
    
    DUSER="${DUSER:-$DEFAULT_USER}"
    DUID="${DUID:-$DEFAULT_UID}"
    DGID="${DGID:-$DEFAULT_GID}"
    
    [[ `id $DUSER > /dev/null` ]] && \
        useradd -u "$DUID" \
                -g "$DGID" \
                -d "/home/$DUSER" -m \
                -s /bin/bash \
                "$DUSER"
    
    echo "$DUSER"
    return 0
}


# Add a user here
USERNAME=$(config_user)

# If no user created, define the current one (root)
[[ `id "$USERNAME"` ]] || USERNAME="$USER"

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
echo " This container is running: '$EXECAPP',"
echo " with arguments: '$DARGS',"
echo " at directory: '$WORKDIR',"
echo " by user: '${USERNAME} (uid:$USERID,gid:$GROUPID)'."
echo "#====================================================#"
echo "" 
if [ "$EXECAPP" != "$_SHELL" ]; then
    su -l $USERNAME -c "cd $WORKDIR && $EXECAPP $DARGS"
else
    cd $WORKDIR && su $USERNAME
fi

