set -e

git filter-branch --prune-empty --subdirectory-filter boomerang --tag-name-filter cat -- --all

UNWANTED=""
UNWANTED="$UNWANTED *.sdf"
UNWANTED="$UNWANTED *.suo"
#UNWANTED="$UNWANTED bin/*.pdb bin/*.exe bin/*.dll bin/*.ilk"
#UNWANTED="$UNWANTED projects/*.suo.old projects/*.sdf projects/*.ncb"
#UNWANTED="$UNWANTED projects/*.suo projects/*.dll"
git filter-branch --force --index-filter "git rm -r --cached --ignore-unmatch $UNWANTED"  --prune-empty --tag-name-filter cat -- --all
git reflog expire --expire=now --all
git gc --aggressive --prune=now
git repack -a -d -f --depth=250 --window=250
# Why do I need to do this twice...
git filter-branch --force --index-filter "git rm -r --cached --ignore-unmatch $UNWANTED"  --prune-empty --tag-name-filter cat -- --all
git reflog expire --expire=now --all
git gc --aggressive --prune=now
git repack -a -d -f --depth=250 --window=250
