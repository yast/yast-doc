STYLESHEET_CSS=style/default.css

all: html

html: yast2_faq.xml
	xsltproc --xinclude --stringparam html.stylesheet $(STYLESHEET_CSS) customize-html.xsl yast2_faq.xml
