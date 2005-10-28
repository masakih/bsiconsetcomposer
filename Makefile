
PRODUCT_NAME=BSIconSetComposer
VERSION=1.0
PRODUCT_EXTENSION=app
BUILD_PATH=./build
DEPLOYMENT=Release
APP_BUNDLE=$(PRODUCT_NAME).$(PRODUCT_EXTENSION)
APP=$(BUILD_PATH)/$(DEPLOYMENT)/$(APP_BUNDLE)
APP_NAME=$(BUILD_PATH)/$(DEPLOYMENT)/$(PRODUCT_NAME)
INFO_PLIST=Info.plist

URL_BSIconSetComposer = svn+ssh://macosx/usr/local/svnrepos005
HEAD = $(URL_BSIconSetComposer)/BSIconSetComposer
TAGS_DIR = $(URL_BSIconSetComposer)/tags

all:
	@echo do  nothig.
	@echo use target tagging 

tagging:
	echo "Tagging the 1.0 (x) release of BSIconSetComposer project."
	ver=`grep -A1 'CFBundleVersion' Info.plist | tail -1 | tr -d '\t</string>'`;    \
	svn copy $(HEAD) $(TAGS_DIR)/release-$${ver}

Localizable: IconSetComposer.m
	genstrings -o English.lproj $<
	(cd English.lproj; ${MAKE} $@;)
	genstrings -o Japanese.lproj $<
	(cd Japanese.lproj; ${MAKE} $@;)

checkLocalizable:
	(cd English.lproj; ${MAKE} $@;)
	(cd Japanese.lproj; ${MAKE} $@;)

release: updateRevision
	xcodebuild -configuration $(DEPLOYMENT)
	$(MAKE) restorInfoPlist
	REV=`svn info | awk '/Last Changed Rev/ {print $$4}'`;	\
	ditto -ck -rsrc $(APP) $(APP_NAME)-$(VERSION)-$${REV}.zip

updateRevision: update_svn
	if [ ! -f $(INFO_PLIST).bak ] ; then cp $(INFO_PLIST) $(INFO_PLIST).bak ; fi ;	\
	REV=`svn info | awk '/Last Changed Rev/ {print $$4}'` ;	\
	sed -e "s/%%%%REVISION%%%%/$${REV}/" $(INFO_PLIST) > $(INFO_PLIST).r ;	\
	mv -f $(INFO_PLIST).r $(INFO_PLIST) ;	\

restorInfoPlist:
	if [ -f $(INFO_PLIST).bak ] ; then cp -f $(INFO_PLIST).bak $(INFO_PLIST) ; fi

update_svn:
	svn up

