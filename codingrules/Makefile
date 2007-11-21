STYLESHEET_CSS=../style/default.css

all: html

html: rules.xml
	echo ""; \
	xsltproc --xinclude --stringparam html.stylesheet $(STYLESHEET_CSS) customize-html.xsl rules.xml; \
	echo ""; \
	mkdir -vp style; \
	cp -av ../webpage/default.css style/;

clean: remove_html

remove_html:
	rm -rvf html
