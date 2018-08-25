#!/bin/bash

function finish {
  nectar_api/bin/nectar_api stop
}
PORT=$1 nectar_api/bin/nectar_api foreground
trap finish EXIT