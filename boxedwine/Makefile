# Makefile for boxedwine conversion using reposurgeon
#
# Steps to using this:
# 1. Make sure reposurgeon and repotool are on your $PATH.
# 2. For svn, set REMOTE_URL to point at the remote repository
#    you want to convert.
#    If the repository is already in a DVCS such as hg or git,
#    set REMOTE_URL to either the normal cloning URL (starting with hg://,
#    git://, etc.) or to the path of a local clone.
# 3. For cvs, set CVS_HOST to the repo hostname and CVS_MODULE to the module,
#    then uncomment the line that builds REMOTE_URL 
#    Note: for CVS hosts other than Sourceforge or Savannah you will need to 
#    include the path to the CVS modules directory after the hostname.
# 4. Set any required read options, such as --user-ignores or --nobranch,
#    by setting READ_OPTIONS.
# 5. Run 'make stubmap' to create a stub author map.
# 6. (Optional) set REPOSURGEON to point at a faster cython build of the tool.
# 7. Run 'make' to build a converted repository.
#
# The reason both first- and second-stage stream files are generated is that,
# especially with Subversion, making the first-stage stream file is often
# painfully slow. By splitting the process, we lower the overhead of
# experiments with the lift script.
#
# For a production-quality conversion you will need to edit the map
# file and the lift script.  During the process you can set EXTRAS to
# name extra metadata such as a comments mailbox.
#
# Afterwards, you can use the headcompare and tagscompare productions
# to check your work.
#

EXTRAS = 
REMOTE_URL = svn://svn.code.sf.net/p/boxedwine/code
#REMOTE_URL = https://boxedwine.googlecode.com/svn/
CVS_HOST = boxedwine.cvs.sourceforge.net
#CVS_HOST = cvs.savannah.gnu.org
CVS_MODULE = boxedwine
#REMOTE_URL = cvs://$(CVS_HOST)/boxedwine\#$(CVS_MODULE)
READ_OPTIONS =
VERBOSITY = "verbose 1"
REPOSURGEON = reposurgeon

# Configuration ends here

.PHONY: local-clobber remote-clobber gitk gc compare clean dist stubmap
# Tell make not to auto-remove tag directories, because it only tries rm 
# and hence fails
.PRECIOUS: boxedwine-%-checkout boxedwine-%-git

default: boxedwine-git

# Build the converted repo from the second-stage fast-import stream
boxedwine-git: boxedwine.fi
	rm -fr boxedwine-git; $(REPOSURGEON) "read <boxedwine.fi" "prefer git" "rebuild boxedwine-git"

# Build the second-stage fast-import stream from the first-stage stream dump
boxedwine.fi: boxedwine.svn boxedwine.opts boxedwine.lift boxedwine.map $(EXTRAS)
	$(REPOSURGEON) $(VERBOSITY) "script boxedwine.opts" "read $(READ_OPTIONS) <boxedwine.svn" "authors read <boxedwine.map" "sourcetype svn" "prefer git" "script boxedwine.lift" "legacy write >boxedwine.fo" "write >boxedwine.fi"

# Build the first-stage stream dump from the local mirror
boxedwine.svn: boxedwine-mirror
	(cd boxedwine-mirror/ >/dev/null; repotool export) >boxedwine.svn

# Build a local mirror of the remote repository
boxedwine-mirror:
	repotool mirror $(REMOTE_URL) boxedwine-mirror

# Make a local checkout of the source mirror for inspection
boxedwine-checkout: boxedwine-mirror
	cd boxedwine-mirror >/dev/null; repotool checkout ../boxedwine-checkout

# Make a local checkout of the source mirror for inspection at a specific tag
boxedwine-%-checkout: boxedwine-mirror
	cd boxedwine-mirror >/dev/null; repotool checkout ../boxedwine-$*-checkout $*

# Force rebuild of first-stage stream from the local mirror on the next make
local-clobber: clean
	rm -fr boxedwine.fi boxedwine-git *~ .rs* boxedwine-conversion.tar.gz boxedwine-*-git

# Force full rebuild from the remote repo on the next make.
remote-clobber: local-clobber
	rm -fr boxedwine.svn boxedwine-mirror boxedwine-checkout boxedwine-*-checkout

# Get the (empty) state of the author mapping from the first-stage stream
stubmap: boxedwine.svn
	$(REPOSURGEON) "read $(READ_OPTIONS) <boxedwine.svn" "authors write >boxedwine.map"

# Compare the histories of the unconverted and converted repositories at head
# and all tags.
EXCLUDE = -x CVS -x .svn -x .git
EXCLUDE += -x .svnignore -x .gitignore
headcompare: boxedwine-mirror boxedwine-git
	repotool compare $(EXCLUDE) boxedwine-mirror boxedwine-git
tagscompare: boxedwine-mirror boxedwine-git
	repotool compare-tags $(EXCLUDE) boxedwine-mirror boxedwine-git
branchescompare: boxedwine-mirror boxedwine-git
	repotool compare-branches $(EXCLUDE) boxedwine-mirror boxedwine-git
allcompare: boxedwine-mirror boxedwine-git
	repotool compare-all $(EXCLUDE) boxedwine-mirror boxedwine-git

# General cleanup and utility
clean:
	rm -fr *~ .rs* boxedwine-conversion.tar.gz *.svn *.fi *.fo

# Bundle up the conversion metadata for shipping
SOURCES = Makefile boxedwine.lift boxedwine.map $(EXTRAS)
boxedwine-conversion.tar.gz: $(SOURCES)
	tar --dereference --transform 's:^:boxedwine-conversion/:' -czvf boxedwine-conversion.tar.gz $(SOURCES)

dist: boxedwine-conversion.tar.gz

#
# The following productions are git-specific
#

# Browse the generated git repository
gitk: boxedwine-git
	cd boxedwine-git; gitk --all

# Run a garbage-collect on the generated git repository.  Import doesn't.
# This repack call is the active part of gc --aggressive.  This call is
# tuned for very large repositories.
gc: boxedwine-git
	cd boxedwine-git; time git -c pack.threads=1 repack -AdF --window=1250 --depth=250
