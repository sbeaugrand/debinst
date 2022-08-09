#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file rebase.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -n "$1" ]; then
    pBranch=$1
fi

cBranch=`git rev-parse --abbrev-ref HEAD`
if [ -z "$pBranch" ]; then
    pBranch=`git log --first-parent --decorate=short | grep commit |\
 grep '(' | sed -e 's/.*(\(.*\)).*/\1/' -e 's/, /\n/g' |\
 grep -v "\(master\|HEAD\|$cBranch\)" | tee /dev/stderr | head -1`
fi
echo
echo "Current branch: $cBranch"
if [ -n "$pBranch" ]; then
    echo "Parent branch:  $pBranch"
    pHash=`git rev-list --parents $pBranch.. | tail -1 | awk '{ print $2 }'`
    echo "Parent hash:    $pHash"
    subject=`git log $pBranch..$cBranch --format=%s | tail -1`
    echo "Subject:        $subject"
    cat <<EOF

# interactive rebase
git add -v .
git commit -m "fixup! $subject"
  # git log --graph
  # git diff --no-color $pBranch >/tmp/diff.patch
git rebase -i `echo $pHash | cut -c-7`
  # git log --graph
  # git diff --no-color HEAD~1 >/tmp/show.patch
  # diff /tmp/diff.patch /tmp/show.patch
git push --force-with-lease
EOF
else
    echo "Parent branch:  not found"
    pBranch="origin/<parent-branch>"
fi
cat <<EOF

# rebase
git fetch
  # git log --graph
  # git diff --no-color $pBranch >/tmp/diff.patch
git rebase $pBranch
  # git log --graph
  # git diff --no-color HEAD~1 >/tmp/show.patch
  # diff /tmp/diff.patch /tmp/show.patch
git push --force-with-lease

EOF
