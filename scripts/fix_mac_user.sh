#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR/../
echo "$USER:x:$(id -u):$(id -g):ns,,,:$HOME:/bin/bash" > mac_passwd
sed -i.backup 's~/etc/passwd:/etc/passwd:ro~./mac_passwd:/etc/passwd:ro~' docker-compose.yml
