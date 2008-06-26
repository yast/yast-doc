#!/bin/bash

# Script for building YaST documentation from SVN
# Lukas Ocilka <locilka@suse.cz>

# where available products are located
SOURCES=$1 # /work/CDs/all/

# name from ${SOURCES}
# full-10.0-i386, full-10.0-x86_64, full-9.3-i386 etc...
PRODUCT=$2

# /yast/doc/SL10.1 for product full-10.1-i386
SEARCHPATH=$3

MAKE_PARAMS=$4

SEARCHDOMAIN="forgeftp.novell.com"

if [ "${PRODUCT}" == "" ] || [ "$SEARCHPATH" == "" ] || [ "${SOURCES}" == "" ]; then
    echo
    echo "Usage: ./_build-www.sh product-base-dir product-name search-path [make params]"
    echo
    echo "Path: e.g., /yast/doc/SL10.1"
    echo "Example: ./_build-www.sh /work/CDs/all/ full-10.1-i386 /yast/doc/SL10.1 '-j 10'"
    echo
    if [ "${SOURCES}" != "" ]; then
	echo "List of available products: "
	for prodname in `ls -1 ${SOURCES}`; do
    	    echo "  "${prodname}
	done
	echo
    fi
    exit 1;
fi

DOCDIR=`pwd`"/"

# Configuration -->>
### TMP directory
TMPDIR="/tmp"
### Location of YaST sources
SRCDIR=${DOCDIR}"../"
### Target directory (built webpage)
TGTDIR=${DOCDIR}"www/"
### Build log
BUILDLOG=${DOCDIR}"_build-www.log"
# <<-- Configuration

checkforerrors() {
    TEST_X=$?
    echo "Checking for errors..."
    if [ $TEST_X != 0 ]; then
	echo "There were some errors... exiting..."
	exit 42;
    fi
}

echo "Building YaST documentation...
------------------------------" > ${BUILDLOG}

echo "Additional make params: "${MAKE_PARAMS} >> ${BUILDLOG}

echo
echo "*** Backing up www directory ***"
echo "| Current directory: "`pwd`
mv -fv ${TGTDIR} ${TGTDIR}../www.backup

echo
echo "*** Checking for installed packages... ***"
NEEDED_PACKAGES="docbook2x
    docbook-css-stylesheets
    docbook-dsssl-stylesheets
    docbook-xml-website
    docbook-xsl-stylesheets
    docbook-simple
    docbook-tdg
    docbook-toys
    docbook-utils
    docbook-xml-slides
    docbook_3
    docbook_4
    perl
    tar
    gzip
    make
    gettext-tools
    gettext-runtime
    perl-XML-Generator
    fop"
echo "Calling zypper install"
zypper in $NEEDED_PACKAGES

rpm -q $NEEDED_PACKAGES || (echo "1 exiting..." && exit 42)
checkforerrors

# This part removes all known .../html/ directories
# with the previous output
echo
echo "*** REMOVING ALREADY BUILT DOCUMENTATION ***"
cd ${DOCDIR}
echo "| Current directory: "`pwd`
rm -rf ${DOCDIR}tdg/html >> ${BUILDLOG}
rm -rf ${DOCDIR}faq/html >> ${BUILDLOG}
rm -rf ${DOCDIR}webpage/html >> ${BUILDLOG}
rm -rf ${DOCDIR}modules/html >> ${BUILDLOG}
rm -rf ${DOCDIR}perlmodules/html >> ${BUILDLOG}
rm -rf ${DOCDIR}scr/html >> ${BUILDLOG}
make clean >> ${BUILDLOG}
make -f Makefile.cvs >> ${BUILDLOG}

# Cleans up the built HTML pages
echo
echo "*** CLEANING ${TGTDIR} ***"
echo "| Current directory: "`pwd`
rm -rf ${TGTDIR} >> ${BUILDLOG}
mkdir -pv ${TGTDIR} >> ${BUILDLOG}

# Prepares source/core
echo
echo "*** CREATING ... in source/core"
cd ${SRCDIR}
cd core
echo "| Current directory: "`pwd`
make -f Makefile.cvs  >> ${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG}

# Creates XML documentation from libyui source
echo
echo "*** CREATING XML SOURCES IN source/libyui/doc ***"
cd ${SRCDIR}
cd libyui
echo "| Current directory: "`pwd`
make -f Makefile.cvs  >> ${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} || (echo "2 exiting..." && exit 42)
checkforerrors

# Creates XML from ycp-ui-bindings
echo
echo "*** CREATING XML SOURCES IN ycp-ui-bindings ***"
cd ${SRCDIR}
cd ycp-ui-bindings
echo "| Current directory: "`pwd`
# because 'doc' is missing there
cp --force SUBDIRS SUBDIRS.doc-build-backup
sed 's/\(.\+\)/\1 doc/' SUBDIRS.doc-build-backup > SUBDIRS
make -f Makefile.cvs >> ${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} || (echo "2 exiting..." && exit 42)
# reverting
mv --force SUBDIRS.doc-build-backup SUBDIRS
checkforerrors

# Creates XML documentation from yast2
echo
echo "*** CREATING XML SOURCES IN source/yast2 ***"
cd ${SRCDIR}
cd yast2
echo "| Current directory: "`pwd`
make -f Makefile.cvs >> ${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG}
# not needed for docu
# make ${MAKE_PARAMS} >> ${BUILDLOG} || (echo "2 exiting..." && exit 42)
checkforerrors

# Creates XML documentation from installation
echo
echo "*** CREATING XML SOURCES IN source/installation ***"
cd ${SRCDIR}
cd installation
echo "| Current directory: "`pwd`
make -f Makefile.cvs >> ${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} || (echo "3 exiting..." && exit 42)
checkforerrors

# Creates XML documentation from wfm/doc
echo
echo "*** CREATING XML SOURCES IN source/core/wfm/doc ***"
cd ${SRCDIR}
cd core/wfm/doc
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} || (echo "4 exiting..." && exit 42)

# Creates UI builtins
cd ${SRCDIR}
cd core/libycp/doc
echo "| Current directory: "`pwd`
rm -rf html
make clean  >> ${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} || (echo "5 exiting..." && exit 42)
checkforerrors

# Checks the main doc directory
# Builds the basic html doc
echo
echo "*** PREPARING ENVIRONMENT ***"
cd ${DOCDIR}
echo "| Current directory: "`pwd`
make -f Makefile.cvs >> ${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} || (echo "6 exiting..." && exit 42)
checkforerrors

# Builds the main menu with index and faq
echo
echo "*** BUILDING MAIN MENU ***"
cd ${DOCDIR}
cd webpage
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG}
rm -rf html >> ${BUILDLOG}
# for the search form
export SEARCHDOMAIN=${SEARCHDOMAIN}; export SEARCHPATH=${SEARCHPATH}; make >> ${BUILDLOG} || (echo "7 exiting..." && exit 42)
checkforerrors

# Builds autoinstallation docu in sources
echo
echo "*** BUILDING AUTOYAST DOCUMENTATION ***"
cd ${SRCDIR}autoinstallation
echo "| Current directory: "`pwd`
make -f Makefile.cvs >> ${BUILDLOG}
make clean  >> ${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} || (echo "8 exiting..." && exit 42)
checkforerrors

# Builds styleguide documentation
echo
echo "*** BUILDING STYLEGUIDE DOCUMENTATION ***"
cd ${DOCDIR}styleguide
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} || (echo "9 exiting..." && exit 42)
checkforerrors

# Builds codingrules documentation
echo
echo "*** BUILDING CODINGRULES DOCUMENTATION ***"
cd ${DOCDIR}codingrules
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} || (echo "10 exiting..." && exit 42)
checkforerrors

# Builds tutorials
echo
echo "*** BUILDING TUTORIALS ***"
cd ${DOCDIR}tutorials
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG}
checkforerrors
make html >> ${BUILDLOG} || (echo "11 exiting..." && exit 42)
checkforerrors

# BUILDING -onefile documents
cd ${DOCDIR}tdg
echo "Creating -onefile documentation in "`pwd`
make html-onefile >> ${BUILDLOG}
checkforerrors

# Copying built docu into the directory for the final www pages
echo "*** COPYING -onefile DOCUMENTATION ***"
mkdir -p cd ${TGTDIR}/onefile >> ${BUILDLOG}
cp -afv ${DOCDIR}modules/modules-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG}
cp -afv ${DOCDIR}perlmodules/perlmodules-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG}
cp -afv ${DOCDIR}scr/scr-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG}
cp -afv ${DOCDIR}styleguide/style-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG}
cp -afv ${DOCDIR}tdg/yast-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG}
cp -afv ${DOCDIR}tdg/tutorial-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG}

echo
echo "*** COPYING MAIN MENU ***"
echo "| Current directory: "`pwd`
cp -arf ${DOCDIR}webpage/html/. ${TGTDIR} >> ${BUILDLOG}

echo
echo "*** COPYING AUTOINSTALLATION ***"
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}autoinstall >> ${BUILDLOG}
cp -arf ${SRCDIR}autoinstallation/doc/html/. ${TGTDIR}autoinstall/ >> ${BUILDLOG}

echo
echo "*** COPYING YCP DOCUMENTATION ***"
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}tdg >> ${BUILDLOG}
cp -arf ${DOCDIR}tdg/html/. ${TGTDIR}tdg/ >> ${BUILDLOG}
mkdir -pv ${TGTDIR}tdg/images/navig/
cp -arf ${DOCDIR}webpage/images/. ${TGTDIR}images/
cp -arf ${DOCDIR}tdg/images/. ${TGTDIR}images/
cp -arf ${DOCDIR}tdg/ui/examples ${TGTDIR}images/

echo
echo "*** COPYING STYLEGUIDE ***"
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}styleguide >> ${BUILDLOG}
cp -arf ${DOCDIR}styleguide/html/. ${TGTDIR}styleguide/ >> ${BUILDLOG}

echo
echo "*** COPYING CODINGRULES ***"
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}codingrules >> ${BUILDLOG}
cp -arf ${DOCDIR}codingrules/html/. ${TGTDIR}codingrules/ >> ${BUILDLOG}

echo
echo "*** COPYING TUTORIALS ***"
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}tutorials >> ${BUILDLOG}
cp -arf ${DOCDIR}tutorials/html/. ${TGTDIR}tutorials/ >> ${BUILDLOG}

# Calls a script which installs YaST-based rpm's from work to the
# ${TMPDIR} directory, builds the YCP Modules, Perl Modules and
# SCR Agents documentation and removes these installed packages
# from the ${TMPDIR} directory again
echo
echo "*** CREATING SCR/MODULES DOC ***"
cd ${DOCDIR}
echo "| Current directory: "`pwd`
echo "Running autogen/autodoc.sh ${PRODUCT} ${DOCDIR} ${TMPDIR} ${TGTDIR} ${SOURCES}"
echo "Running autogen/autodoc.sh ${PRODUCT} ${DOCDIR} ${TMPDIR} ${TGTDIR} ${SOURCES}" >> ${BUILDLOG}
autogen/autodoc.sh ${PRODUCT} ${DOCDIR} ${TMPDIR} ${TGTDIR} ${SOURCES} >> ${BUILDLOG}
checkforerrors

# Removes all /.svn/... directories from the www pages
# Because they shouldn't go to the final page
echo
echo "*** REMOVING .svn DIRECTORIES ***"
cd ${TGTDIR}
echo "| Current directory: "`pwd`
for file in `find | grep "\.svn"`; do rm -rf $file; done

echo
echo "*** Creating TGZ archive '"${PRODUCT}".tgz' from all the documentation ***"
cd ${TGTDIR}
echo "| Current directory: "`pwd`
tar -zcf yast-documentation.tgz *
mkdir -pv ${TGTDIR}download/
mv -fv yast-documentation.tgz ${TGTDIR}download/

echo
echo "*** DONE ***"
echo
echo "==========================================================================="
echo "Built webpage can be found in the ${TGTDIR} directory"
echo "==========================================================================="
echo
