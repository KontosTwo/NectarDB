#!/bin/bash

function finish {
  nectar_api/bin/nectar_api stop
}
nectar_api/bin/nectar_api foreground
trap finish EXIT