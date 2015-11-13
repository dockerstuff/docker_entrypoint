#!/bin/bash -e
#================================================#
# Script to config a User for docker container.  #
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
    exit 0

DUSER="${DUSER-$DEFAULT_USER}"
DUID="${DUID-$DEFAULT_UID}"
DGID="${DGID-$DEFAULT_GID}"

useradd -u "$DUID" \
        -g "$DGID" \
        -d "/home/$DUSER" -m \
        -s /bin/bash \
        "$DUSER"

echo $DUSER

