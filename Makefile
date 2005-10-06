
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

