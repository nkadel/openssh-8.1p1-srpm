#
# Build mock and local RPM versions of tools for Samba
#

# Assure that sorting is case sensitive
LANG=C

MOCKS+=fedora-30-x86_64
MOCKS+=epel-8-x86_64
MOCKS+=epel-7-x86_64
MOCKS+=epel-6-x86_64

SPEC := `ls *.spec`

all:: $(MOCKS)

getsrc:: FORCE
	spectool -g $(SPEC)

src.rpm:: Makefile openssh.spec
	@echo "Building SRC.RPM with $(SPEC)"
	rm -rf rpmbuild
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--define '_sourcedir $(PWD)' \
		-bs $(SPEC) --nodeps
	ln -f $(PWD)/rpmbuild/SRPMS/*.src.rpm $@

build:: src.rpm FORCE
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--rebuild rpmbuild/SRPMS/*.src.rpm

$(MOCKS):: src.rpm FORCE
	@if [ -e $@ -a -n "`find $@ -name \*.rpm`" ]; then \
		echo "	Skipping RPM populated $@"; \
	else \
		echo "	Building $@ RPMS with $(SPEC)"; \
		rm -rf $@; \
		echo "Storing $@/*.src.rpm in $@.rpm"; \
		/bin/mv $@/*.src.rpm $@.src.rpm; \
		echo "Actally building RPMS in $@"; \
		rm -rf $@; \
		mock -q -r /etc/mock/$@.cfg \
		     --resultdir=$(PWD)/$@ \
		     src.rpm; \
	fi

mock:: $(MOCKS)

clean::
	rm -rf */
	rm -rf rpmbuild
	rm -f *.out

realclean distclean:: clean
	rm -f *.rpm

FORCE:
