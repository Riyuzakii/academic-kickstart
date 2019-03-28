#!/bin/bash

hugo

git add .
git commit -m "value prediction post"
git push -u origin master

cd ./public
git add .
git commit -m "value prediction post"
git push origin master
