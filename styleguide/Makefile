STYLESHEET_CSS=../style/default.css

all: html

html: style.xml
	xsltproc --xinclude --stringparam html.stylesheet $(STYLESHEET_CSS) customize-html.xsl style.xml

clean: remove_html

remove_html:
	rm -rvf html
