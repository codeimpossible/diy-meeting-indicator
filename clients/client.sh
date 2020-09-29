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
if [ $1 = "install" ]; then
  INSTALL="true"
  IP="$2"
  if [[ "$IP" == "" ]]; then
    echo "$date ERR!: Must specify an IP during install."
    exit 1
  fi
fi
SCRIPT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

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

function log() {
  msg="$1"
  date=$(date '+%Y-%m-%d %H:%M:%S')
  printf "$date $msg\n"
}

function install {
  crontab -l > _cron || true
  echo "* * * * * $SCRIPT/client.sh $IP" >> _cron
  crontab _cron
  rm _cron
  
  echo "installed successfully."
}

function main {
  log "v1.1 running..."
  if [ "$1" = "help" ]; then
    usage
    return 0
  fi

  if [[ "$INSTALL" == "true" ]]; then
    install
  else
    lastState=""
    if [ -f "$SCRIPT/_lastState" ]; then
      lastState=$(/bin/cat "$SCRIPT/_lastState");
    fi
    
    log "lastState=$lastState"

    # check for zoom call
    log "checking for zoom calls..."
    status=$(/usr/sbin/lsof -i | grep zoom.us | grep UDP | /usr/bin/wc -l | xargs)
    if [ "$status" != "0" ]; then
      status="1"
    fi
    
    log "lastStatus ($lastState) == status ($status)?"
    if [ "$lastState" != "$status" ]; then
      log "sending status=$status to indicator..."
      curl -X PUT -H "Content-Type: application/json" --data "{ \"status\": $status }" http://$IP/status
      echo $status > $SCRIPT/_lastState
    else 
      log "lastStatus ($lastState) == status ($status). Exiting."
    fi
  fi
}

main
