# !/usr/bin/env bash

cd /tmp
git clone -q https://github.com/dfunkt/go
cd go/src
# https://github.com/dfunkt/go/commit/672bb0b589dde124999d4184883aa3921cf55173 is version go1.22.6-devel-cf
git checkout -q 672bb0b589dde124999d4184883aa3921cf55173
./make.bash
