#!/usr/bin/env bash

# *Nix/OSX Client Script
# =======================
# Copy onto your machine and run 
# ./client install <<PI_IP>>
# to setup the script. Replace <<PI_IP>> with the IP
# of your raspberry pi device.

set -e

INSTALL="false"
IP="$1"
if [ $1="install" ]; then
  INSTALL="true"
  IP="$2"
fi
SCRIPT="${BASH_SOURCE[0]}"

# Prints out the usage instructions for this script
function usage {
  echo "Usage: $0 [install|help] ip"
  echo "  install           Optional. Specifies that the script should install the client task locally."
  echo "  help              Shows this help message."
  echo "  ip                The IP Address of your raspberry pi."
  echo ""
  echo "Example (with install):   $0 install 192.168.1.123"
  echo "Example (without install): $0 192.168.1.123"
}

function install {
  crontab -l > _cron
  echo "* * * * * $SCRIPT $IP" >> _cron
  crontab _cron
  rm _cron
  
  echo "installed successfully."
}

function main {
  if [ $1="help"]; then
    usage
    return 0
  fi
  
  if [[ "$INSTALL" == "true" ]]; then
    install
  else
    # check for zoom call
    status=$(lsof -i | grep zoom.us | grep UDP | wc -l | xargs)
    curl -x POST -H "Content-Type: application/json" --data '{"status": $status}' http://$IP:8000/api/status
  fi
}

main "$@"
