#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# filter-branch backs up anything that got rewritten under original/
clean_after_filter() {
    git checkout master
    git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d # git show-ref
}

git tag -d $(git tag)
git branch -D libc
# it'd be nice to use subdirectory-filter, but there are some merge commits and for some reason
# the branches they were merged from do not have all the files under boxedwine/. to reconcile,
# just bring things up a level when boxedwine is a directory
git filter-branch --prune-empty --tree-filter 'set -e; if [ -d boxedwine ]; then mv boxedwine/* .; rmdir boxedwine; fi' --tag-name-filter cat -- --all
clean_after_filter
git checkout master

UNWANTED=""
UNWANTED="$UNWANTED *.sdf"
UNWANTED="$UNWANTED *.suo"
UNWANTED="$UNWANTED *.msi" # part of the root FS at some point in the past, but seems to be never used
git filter-branch --force --index-filter "git rm -r --cached --ignore-unmatch $UNWANTED" --prune-empty --tag-name-filter cat -- --all
clean_after_filter
git reflog expire --expire=now --all
git gc --aggressive --prune=now
git repack -a -d -f --depth=250 --window=250
