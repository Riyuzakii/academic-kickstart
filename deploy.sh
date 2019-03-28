#!/bin/bash

hugo

git add .
git commit -m "site update"
git push -u origin master

cd ./public
git add .
git commit -m "site update real"
git push origin master
