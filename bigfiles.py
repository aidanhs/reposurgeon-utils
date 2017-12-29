#!/usr/bin/env python

import os, sys

def getOutput(cmd):
    return os.popen(cmd).read()

if (len(sys.argv) <> 2 and False):
    print "usage: %s size_in_bytes" % sys.argv[0]
else:

    revisions = getOutput("git rev-list --all").split()

    objs = set()
    deets = dict()
    for revision in revisions:
        files = getOutput("git ls-tree -zrl %s" % revision).split('\0')
        for f in files:
            if f == "":
                continue
            _mode, _type, obj, size_and_path = f.split(' ', 3)
            size, path = size_and_path.split('\t', 1)
            # If no size
            if size == "-":
                continue
            size = int(size)

            if obj in objs:
                continue
            objs.add(obj)

            if path in deets:
                sumsize, count, rev = deets[path]
                deets[path] = (sumsize + size, count + 1, rev)
            else:
                deets[path] = (size, 1, revision)

    bigfiles = sorted(deets.items(), key=lambda x: x[1], reverse=True)

    for path, (sumsize, count, rev) in bigfiles:
        print "%s %.2fM in %s commits (e.g. %s)" % (path, float(sumsize)/1024/1024, count, rev)
