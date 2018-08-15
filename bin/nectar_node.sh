#!/bin/bash

function finish {
  nectar_node/bin/nectar_node stop
}
REPLACE_OS_VARS=true NODENAME=$1 APINODENAME=$2 nectar_node/bin/nectar_node foreground
trap finish EXIT