#!/usr/bin/env bash

if [[ $1 == "test" ]]
then
	cd tests

	odin test ../tests -all-packages -collection:src=../src
	exit 0
fi

if [[ $1 == "run" ]]
then
	odin run ./src -collection:src=src
	exit 0
fi

if [[ $1 == "debug" ]]
then
	odin run ./src -collection:src=src -debug
	exit 0
fi

if [[ $1 == "speed" ]]
then
	odin run ./src -collection:src=src -o:speed
	exit 0
fi

odin build ./src -collection:src=src


