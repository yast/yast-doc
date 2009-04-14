#!/bin/bash

STYLESHEET_CSS="../style/default.css"

echo "Calling ./pod2xml.pl ${1}/usr/share/YaST2/modules/*.pm ${1}/usr/share/YaST2/modules/YaPI/*.pm > index.xml"
./pod2xml.pl $1/usr/share/YaST2/modules/*.pm $1/usr/share/YaST2/modules/YaPI/*.pm > index.xml

/bin/mkdir -p ./html/
/usr/bin/xsltproc --xinclude --stringparam html.stylesheet ${STYLESHEET_CSS} customize-html.xsl index.xml
/usr/bin/xsltproc --xinclude --stringparam html.stylesheet ${STYLESHEET_CSS} ../customize-html-onefile.xsl index.xml > perlmodules-onefile.html
/bin/mkdir -pv style
/bin/cp -a ../webpage/default.css style/
/bin/mkdir -pv images
/bin/cp -ar ../webpage/images/ .
