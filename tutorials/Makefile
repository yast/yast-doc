STYLESHEET_CSS=../style/default.css

all: html

html: tutorial.xml
	echo ""; \
	xsltproc --xinclude --stringparam html.stylesheet $(STYLESHEET_CSS) customize-html.xsl tutorial.xml; \
	xsltproc --xinclude --stringparam html.stylesheet $(STYLESHEET_CSS) ../customize-html-onefile.xsl tutorial.xml > tutorial-onefile.html; \
	echo ""; \
	mkdir -vp html/screenshots; \
	cp -a tutorial-screenshots/* html/screenshots; \
	mkdir -vp html/sources; \
	cp -a tutorial-sources/* html/sources; \
	mkdir -vp style; \
	cp -av ../webpage/default.css style/;

clean: remove_html

remove_html:
	rm -rf html
