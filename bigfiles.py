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
            splitdata = f.split()
            # If no size
            if splitdata[3] == "-":
                continue

            obj = splitdata[2]
            size = int(splitdata[3])
            path = splitdata[4]

            if obj in objs:
                continue
            objs.add(obj)

            if path in deets:
                deets[path] = deets[path] + 1
            else:
                deets[path] = 1

    bigfiles = sorted(deets.items(), key=lambda x: x[1], reverse=True)

    for f in bigfiles:
        print "%s %s" % (f[0], str(f[1]))
