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

[[ "$USERNAME" = "0" ]] && USERNAME="$USER"

su -l $USERNAME -c "$INTERP $DARGS"

