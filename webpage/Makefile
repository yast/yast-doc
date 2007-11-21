PROC=xsltproc
STYLEDIR=./xsl
TABSTYLE=./xsl/mine.xsl
STYLESHEET=$(TABSTYLE)
# Change the path in output-root to put your HTML output elsewhere
DESTDIR=html

# Call the config file
include config.sh

STYLEOPT= --stringparam output-root $(DESTDIR) \
	--xinclude \
	-stringparam admon.graphics 1 \
	--stringparam search-domain $(SEARCHDOMAIN) \
	--stringparam search-path $(SEARCHPATH) \
	--stringparam site-logo-url $(SITELOGOURL) \
	--stringparam site-logo-x $(SITELOGO_X) \
	--stringparam site-logo-y $(SITELOGO_Y)
CATALOG=./catalog.xml

.PHONY : clean 

all: faq_prepare faq style images 
	make website

include depends.tabular

faq_prepare:
	xmllint --xinclude --noent ../faq/faq_website.xml > faq.xml

faq: faq.xml

autolayout.xml: layout.xml
	$(PROC) --output $@ $(STYLEDIR)/autolayout.xsl $<
	make depends

%.html: autolayout.xml 
	$(PROC) --output $@  $(STYLEOPT)  $(STYLESHEET)  $(filter-out autolayout.xml,$^) 

depends: autolayout.xml
	$(PROC) --output depends.tabular $(STYLEOPT) $(STYLEDIR)/makefile-dep.xsl $<

sync:
	rsync -avz -e ssh  $(DESTDIR)/* minkowski:~/public_html/yast2-docs

sync-intern:
	rsync --exclude=CVS -avz -e ssh  $(DESTDIR)/* minkowski:~/Export/yast2-docs

style: $(DESTDIR)/style/default.css

$(DESTDIR)/style/default.css:
	mkdir -p $(DESTDIR)/style
	cp default.css $(DESTDIR)/style

$(DESTDIR)/images:
	mkdir -p $(DESTDIR)/images

images: $(DESTDIR)/images
	cp -a images $(DESTDIR)/

