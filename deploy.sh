#!/bin/bash

hugo
commit_msg=$1
# echo $commit_msg
git add .
git commit -m $commit_msg
git push -u origin master

cd ./public
git add .
git commit -m $commit_msg
git push origin master
