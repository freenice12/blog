#!/bin/bash

echo "========="
echo "publising"
echo "========="

hugo -t harbor

cd public
git add .
msg="hugo build: `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"
git push

cd ..
git add .
msg="published: `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"
git push