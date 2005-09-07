
URL_BSIconSetComposer = svn+ssh://macosx/usr/local/svnrepos004
HEAD = $(URL_BSIconSetComposer)/BSIconSetComposer
TAGS_DIR = $(URL_BSIconSetComposer)/tags

all:
	@echo do  nothig.
	@echo use target tagging 

tagging:
	echo Tagging the x.x.x release of BSIconSetComposer project.
	ver=`grep -A1 'CFBundleVersion' Info.plist | tail -1 | tr -d '\t</string>'`;    \
	svn copy $(HEAD) $(TAGS_DIR)/release-$${ver}
