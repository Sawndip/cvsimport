#!/bin/bash

# Export commits from git master to the current CVS checkout. Expects a git tag
# called synccvs to point to the place in the git repo where CVS is up-to-date.
# Any commits between synccvs and master in git will be exported to CVS.
#
# Usage:
# ./synccvs.sh [-f]
# 
# By default the script will only print out what would be committed to CVS. To
# get it to commit anything use -f.

if [ 0 -ne `git status | grep -c 'modified'` ]; then
  echo -ne "Warning: git is not up-to-date. "
  read -p "Do you want to continue? [y/N] "
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit
  fi
fi

synccvs=`git show synccvs | grep commit`
master=`git show master | grep commit`
if [ "$synccvs" = "$master" ]; then
  echo "Everything seems up-to-date"
else
  echo "synccvs tag is currently at $synccvs"
  echo "master is currently at $master"
  if [ "$1" = "-f" ]; then
    git checkout synccvs
    git cherry synccvs master | sed 's/^+ //' | tail -r | xargs -n1 git cvsexportcommit -c -p -v
    git checkout -f master
    git tag -f synccvs
    exit
  else
    echo "The following would be committed:"
    git cherry synccvs master | sed 's/^+ //' | tail -r
  fi
fi
