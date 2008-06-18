#!/bin/bash

STYLESHEET_CSS="../style/default.css"

/usr/lib/YaST2/bin/ycpdoc -f xml $1/usr/share/YaST2/modules/*.ycp

/usr/bin/recode latin2..utf-8 ycpdoc.xml
/usr/bin/xsltproc --xinclude yast2_modules.xslt ycpdoc.xml > index.xml
/bin/mkdir -p ./html/
/usr/bin/xsltproc --xinclude --stringparam html.stylesheet ${STYLESHEET_CSS} customize-html.xsl index.xml
/usr/bin/xsltproc --xinclude --stringparam html.stylesheet ${STYLESHEET_CSS} ../customize-html-onefile.xsl index.xml > modules-onefile.html
/bin/mkdir -pv style
/bin/cp -av ../webpage/default.css style/
/bin/mkdir -pv images
/bin/cp -avr ../webpage/images/ .
