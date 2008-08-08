#!/bin/bash

XSLTPROC=$1
HTMLCSS=$2

if [ "${XSLTPROC}" == "" ] || [ "${HTMLCSS}" == "" ]; then
    echo
    echo "Usage"
    echo "./build-by-books.sh path-to-xsltproc included-html-css"
    echo

    exit 42
fi

echo "XSLT Proc: " ${XSLTPROC}
echo "HTML CSS: " ${HTMLCSS}

for bookID in `cat list_of_books.txt`; do
    echo "Building Book with ID "${bookID}
    ${XSLTPROC} --xinclude \
    --stringparam html.stylesheet "${HTMLCSS} ../${HTMLCSS}" \
    --stringparam rootid "${bookID}" \
    customize-html.xsl yast.xml
done
