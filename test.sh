#!/usr/bin/env bash

function cleanup {
    pkill -f iex
    echo "Shutting down test"
}

trap cleanup EXIT

iex --sname test1@localhost &
mix test
wait
