#
# Makefile.am 
#

XMLFILES=$(wildcard *.xml introduction/*.xml)
SUBDIRS =  installation development ycp ui pkg-bindings library
STYLESHEET_CSS = ../style/default.css

all-local: html

htmldir = $(docdir)/yast

html: $(XMLFILES) html/index.html html/examples html/screenshots html/images

pdf: $(XMLFILES) yast.pdf

validate:
	XML_CATALOG_FILES=@XML_CATALOG@\
	@XSLTPROC@ --xinclude --valid --noout yast.xml

yast.fo: yast.xml
	XML_CATALOG_FILES=@XML_CATALOG@\
	@XSLTPROC@ --xinclude -o yast.fo @STYLESHEET_PDF@  yast.xml

yast.pdf: yast.fo
	fop -q yast.fo yast.pdf

html/yast2docs.css:
	cp -a $(ydatadir)/docbook/images html
	cp -a images/* html/images

html/examples:
	cp -a ui/examples html

html/screenshots:
	cp -a library/screenshots html

docu-index:
	@XSLTPROC@ --xinclude index.xsl yast.xml > index.xml
	@XSLTPROC@ --xinclude --stringparam html.stylesheet $(STYLESHEET_CSS) index-html.xsl index.xml
	rm -rf index.xml

build-books:
	./build-by-books.sh @XSLTPROC@ $(STYLESHEET_CSS)

# 'docu-index' must be called before 'build-books'
html/index.html: yast.xml docu-index build-books

html/images:
	mkdir -p html/images
	cp -a images/* html/images

html_DATA = $(wildcard html/*) 

EXTRA_DIST = *.xml $(html_DATA)

CLEANFILES = CATALOG.local *.out *.aux *.dvi *.tex *.ps *.pdf *.log *.dsl *.fo ChangeLog ChangeLog.xml

clean-local:
	rm -rf html/*
