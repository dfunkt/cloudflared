# !/usr/bin/env bash

cd /tmp
git clone -q https://github.com/dfunkt/go
cd go/src
# https://github.com/dfunkt/go/commit/b6fd0f9d1ea8e4a5ae2ca42c402e326f0940d7f6 is version go1.22.4-devel-cf
git checkout -q b6fd0f9d1ea8e4a5ae2ca42c402e326f0940d7f6
./make.bash
