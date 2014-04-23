# set EXTRAREV to append something to the RPM revision, e.g. EXTRAREV=.is24

# this goes into the src archive and this is relevant for the revision
TOPLEVEL := chown_subdirs_in_dir hadoop-utils.spec Makefile

GITREV := HEAD

REVISION := "$(shell git rev-list $(GITREV) -- $(TOPLEVEL) 2>/dev/null | wc -l)"
VERSION := $(shell cat VERSION 2>/dev/null).$(REVISION)
PV = hadoop-utils-$(VERSION)

# make sure to build RHEL5-compatible RPMs

RPMBUILD_OPTS := --define="_binary_payload w9.bzdio" --define="_source_filedigest_algorithm md5" --define="_binary_filedigest_algorithm md5"

.PHONY: all srpm clean rpm info rpminfo

all: rpminfo
	ls -l dist/

tgz: clean
	@echo "Creating TAR.GZ"
	mkdir -p dist build/$(PV) build/BUILD
	cp -r $(TOPLEVEL) build/$(PV)
	mv build/$(PV)/*.spec build/
	sed -i -e "s/__VERSION__/$(VERSION)/" -e "s/__EXTRAREV__/$(EXTRAREV)/" build/*.spec
	tar -czf dist/$(PV).tar.gz -C build $(PV)

srpm: tgz
	@echo "Creating SOURCE RPM"
	rpmbuild $(RPMBUILD_OPTS) --define="_topdir $(CURDIR)/build" --define="_sourcedir $(CURDIR)/dist" --define="_srcrpmdir $(CURDIR)/dist" --nodeps -bs build/*.spec

rpm: srpm
	@echo "Creating BINARY RPM"
	ln -svf ../dist build/noarch
	rpmbuild $(RPMBUILD_OPTS) --define="_topdir $(CURDIR)/build" --define="_rpmdir %{_topdir}" --rebuild $(CURDIR)/dist/*.src.rpm
	@echo
	@echo
	@echo
	@echo 'WARNING! THIS RPM IS NOT INTENDED FOR PRODUCTION USE. PLEASE USE rpmbuild --rebuild dist/*.src.rpm TO CREATE A PRODUCTION RPM PACKAGE!'
	@echo
	@echo
	@echo

info: rpminfo

rpminfo: rpm
	rpm -qip dist/*.noarch.rpm

rpmrepo: rpm
	echo "##teamcity[buildStatus text='{build.status.text} RPM Version $(shell rpm -qp dist/*src.rpm --queryformat "%{VERSION}-%{RELEASE}")']"
	repoclient uploadto "$(TARGET_REPO)" dist/*.rpm

clean:
	rm -Rf dist build

# todo: create debian/RPM changelog automatically, e.g. with git-dch --full --id-length=10 --ignore-regex '^fixes$' -S -s 68809505c5dea13ba18a8f517e82aa4f74d79acb src doc *.spec

