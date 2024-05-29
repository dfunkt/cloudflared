# !/usr/bin/env bash

cd /tmp
git clone -q https://github.com/cloudflare/go
cd go/src
# https://github.com/cloudflare/go/tree/048a67333ee3148de8334b397deb5901000339bb is version go1.22.3-devel-cf
git checkout -q 048a67333ee3148de8334b397deb5901000339bb
./make.bash
