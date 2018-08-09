#!/usr/bin/env bash

function cleanup {
    pkill -f iex
    echo "Shutting down test"
}

trap cleanup EXIT

iex --sname test1@localhost &
iex -S mix test
wait
