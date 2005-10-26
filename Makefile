
PRODUCT_NAME=BSIconSetComposer
PRODUCT_EXTENSION=app
BUILD_PATH=./build/
DEPLOYMENT=Release
APP_BUNDLE=$(PRODUCT_NAME).$(PRODUCT_EXTENSION)
APP_BINARY=$(BUILD_PATH)/$(DEPLOYMENT)/$(APP_BUNDLE)/Contents/MacOS/$(PRODUCT_NAME)
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

release:
	

changeRevision: update_svn
	if [ ! -f $(INFO_PLIST).bak ] ; then cp $(INFO_PLIST) $(INFO_PLIST).bak ; fi ;	\
	REV=(svn info | awk '/Revision/ {print $$2}') ;	\
	REV=expr $$(REV) + 1 ;	\
	sed -e 's/%%%%REVISION%%%%/$$(REV)/' $(INFO_PLIST) > $(INFO_PLIST).r ;	\
	mv -f $(INFO_PLIST).r $(INFO_PLIST) ;	\
	svn ci -m "change build number to $REV" $(INFO_PLIST) ;	\
	$(MAKE) restorInfoPlist

restorInfoPlist:
	if [ -f $(INFO_PLIST).bak ] ; then cp -f $(INFO_PLIST).bak $(INFO_PLIST)

update_svn:
	svn up

