#!/bin/bash
#git clone git@github.com:zhaozhao27/zhaozhao27.github.io.git -c core.symlinks=true
#cd zhaozhao27.github.io/
git submodule init
git submodule add https://gitlab.com/cyril-marpaud/hayflow.git themes/hayflow
git submodule add https://codeberg.org/daudix/duckquill.git themes/duckquill

git submodule update --remote --merge
cd themes/duckquill/
git checkout tags/v6.0.0
cd -
