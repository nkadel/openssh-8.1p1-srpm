#
# Build mock and local RPM versions of tools for Samba
#

# Assure that sorting is case sensitive
LANG=C

MOCKS+=epel-7-x86_64

SPEC := `ls *.spec`

all:: verifyspec $(MOCKS)

# Oddness to get deduced .spec file verified
verifyspec:: FORCE
	@if [ ! -e $(SPEC) ]; then \
	    echo Error: SPEC file $(SPEC) not found, exiting; \
	    exit 1; \
	fi

srpm:: verifyspec FORCE
	@echo "Building SRPM with $(SPEC)"
	rm -rf rpmbuild
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--define '_sourcedir $(PWD)' \
		-bs $(SPEC) --nodeps

build:: srpm FORCE
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--rebuild rpmbuild/SRPMS/*.src.rpm

$(MOCKS):: verifyspec FORCE
	@if [ -e $@ -a -n "`find $@ -name \*.rpm`" ]; then \
		echo "	Skipping RPM populated $@"; \
	else \
		echo "	Building $@ RPMS with $(SPEC)"; \
		rm -rf $@; \
		mock -q -r /etc/mock/$@.cfg \
		    --resultdir=$(PWD)/$@ \
		    --sources=$(PWD) --buildsrpm --spec=$(SPEC); \
		echo "Storing $@/*.src.rpm in $@.rpm"; \
		/bin/mv $@/*.src.rpm $@.src.rpm; \
		echo "Actally building RPMS in $@"; \
		rm -rf $@; \
		mock -q -r /etc/mock/$@.cfg \
		     --resultdir=$(PWD)/$@ \
		     $@.src.rpm; \
	fi

mock:: $(MOCKS)

clean::
	rm -rf */
	rm -rf rpmbuild
	rm -f *.out

realclean distclean:: clean
	rm -f *.rpm

FORCE:
