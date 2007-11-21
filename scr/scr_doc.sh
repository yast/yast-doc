#!/bin/bash

### This script creates documentation for scr agents
### 1st parameter is a prefix of root directory:
###    -> '/tmp/tmproot' makes the script take scragents
###       from '/tmp/tmproot/usr/share/YaST2/scrconf/' dir

STYLESHEET_CSS="../style/default.css"

/usr/lib/YaST2/bin/scrdoc -f xml $1/usr/share/YaST2/scrconf/*.scr

/usr/bin/recode latin2..utf-8 output.xml

TMPFILE="tmp_output.xml"
/bin/sed '
    s/&lt;tt&gt;/<literal>/g
    s/&lt;\/tt&gt;/<\/literal>/g
    s/&lt;b&gt;/<literal>/g
    s/&lt;\/b&gt;/<\/literal>/g
    s/&lt;p&gt;//g
    s/&lt;\/p&gt;/<br\/>/g
    s/&lt;br&gt;/<br\/>/g
' output.xml > $TMPFILE
/bin/mv -f $TMPFILE output.xml

/usr/bin/xsltproc --xinclude yast2_scr.xslt output.xml > index.xml
/bin/mkdir -p ./html/
/usr/bin/xsltproc --xinclude --stringparam html.stylesheet ${STYLESHEET_CSS} customize-html.xsl index.xml
/bin/mkdir -pv style
/bin/cp -a ../webpage/default.css style/
/bin/mkdir -pv images
/bin/cp -ar ../webpage/images/ .
