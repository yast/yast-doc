#!/bin/bash

# Script for building YaST documentation from SVN
# Lukas Ocilka <locilka@suse.cz>

# name from /work
# full-10.0-i386, full-10.0-x86_64, full-9.3-i386 etc...
PRODUCT=$1
SEARCHPATH=$2 # /yast/doc/SL10.1 for product full-10.1-i386
SEARCHDOMAIN="forgeftp.novell.com"

# where available products are located
SOURCES="/work/CDs/all/"

if [ "${PRODUCT}" == "" ] || [ "$SEARCHPATH" == "" ]; then
    echo
    echo "Usage: ./_build-www.sh product-name search-path"
    echo
    echo "Path: e.g., /yast/doc/SL10.1"
    echo
    echo "List of available products: "
    for prodname in `ls -1 ${SOURCES}`; do
        echo "  "${prodname}
    done
    echo
    exit 1;
fi

DOCDIR=`pwd`"/"

# Configuration -->>
### TMP directory
TMPDIR="/tmp"
### Location of YaST sources
SRCDIR=${DOCDIR}"../source/"
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

echo -n > ${BUILDLOG}

echo
echo "*** Backing up www directory ***"
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
    gettext
    gettext-devel
    perl
    tar
    gzip
    make
    gettext-devel"
rpm -q $NEEDED_PACKAGES || (echo "1 exiting..." && exit 42)
checkforerrors

# This part removes all known .../html/ directories
# with the previous output
echo
echo "*** REMOVING ALREADY BUILT DOCUMENTATION ***"
cd ${DOCDIR}
rm -rf ${DOCDIR}tdg/html >> ${BUILDLOG}
rm -rf ${DOCDIR}faq/html >> ${BUILDLOG}
rm -rf ${DOCDIR}webpage/html >> ${BUILDLOG}
rm -rf ${DOCDIR}modules/html >> ${BUILDLOG}
rm -rf ${DOCDIR}perlmodules/html >> ${BUILDLOG}
rm -rf ${DOCDIR}scr/html >> ${BUILDLOG}
make clean
make -f Makefile.cvs

# Cleans up the built HTML pages
echo
echo "*** CLEANING ${TGTDIR} ***"
rm -rf ${TGTDIR} >> ${BUILDLOG}
mkdir -pv ${TGTDIR} >> ${BUILDLOG}

# Creates XML documentation from libyui source
echo
echo "*** CREATING XML SOURCES IN source/core/libyui/doc ***"
cd ${SRCDIR}
cd core
make -f Makefile.cvs >> ${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG}
cd libyui/doc
make || (echo "2 exiting..." && exit 42)
checkforerrors

# Creates XML documentation from yast2
echo
echo "*** CREATING XML SOURCES IN source/yast2 ***"
cd ${SRCDIR}
cd yast2
make -f Makefile.cvs >> ${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG}
make || (echo "2 exiting..." && exit 42)
checkforerrors

# Creates XML documentation from installation
echo
echo "*** CREATING XML SOURCES IN source/installation ***"
cd ${SRCDIR}
cd installation
make -f Makefile.cvs >> ${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG}
make || (echo "3 exiting..." && exit 42)
checkforerrors

# Creates XML documentation from wfm/doc
echo
echo "*** CREATING XML SOURCES IN source/core/wfm/doc ***"
cd ${SRCDIR}
cd core/wfm/doc
make clean >> ${BUILDLOG}
cd libyui/doc
make || (echo "4 exiting..." && exit 42)
checkforerrors

# Creates UI builtins
cd ${SRCDIR}
cd core/libycp/doc
make || (echo "5 exiting..." && exit 42)
checkforerrors

# Checks the main doc directory
# Builds the basic html doc
echo
echo "*** PREPARING ENVIRONMENT ***"
cd ${DOCDIR}
make -f Makefile.cvs >> ${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG}
checkforerrors
make || (echo "6 exiting..." && exit 42)
checkforerrors

# Builds the main menu with index and faq
echo
echo "*** BUILDING MAIN MENU ***"
cd ${DOCDIR}
cd webpage
make clean >> ${BUILDLOG}
rm -rf html >> ${BUILDLOG}
# for the search form
export SEARCHDOMAIN=${SEARCHDOMAIN}; export SEARCHPATH=${SEARCHPATH}; make >> ${BUILDLOG} || (echo "7 exiting..." && exit 42)
checkforerrors

# Builds autoinstallation docu in sources
echo
echo "*** BUILDING AUTOYAST DOCUMENTATION ***"
cd ${SRCDIR}autoinstallation
make -f Makefile.cvs >> ${BUILDLOG}
make clean
checkforerrors
make >> ${BUILDLOG} || (echo "8 exiting..." && exit 42)
checkforerrors

# Builds styleguide documentation
echo
echo "*** BUILDING STYLEGUIDE DOCUMENTATION ***"
cd ${DOCDIR}styleguide
make clean >> ${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} || (echo "9 exiting..." && exit 42)
checkforerrors

# Builds codingrules documentation
echo
echo "*** BUILDING CODINGRULES DOCUMENTATION ***"
cd ${DOCDIR}codingrules
make clean >> ${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} || (echo "10 exiting..." && exit 42)
checkforerrors

# Builds tutorials
echo
echo "*** BUILDING TUTORIALS ***"
cd ${DOCDIR}tutorials
make clean >> ${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} || (echo "11 exiting..." && exit 42)
checkforerrors

# Copying built docu into the directory for the final www pages
echo
echo "*** COPYING MAIN MENU ***"
cp -arf ${DOCDIR}webpage/html/. ${TGTDIR} >> ${BUILDLOG}

echo
echo "*** COPYING AUTOINSTALLATION ***"
mkdir -pv ${TGTDIR}autoinstall >> ${BUILDLOG}
cp -arf ${SRCDIR}autoinstallation/doc/html/. ${TGTDIR}autoinstall/ >> ${BUILDLOG}

echo
echo "*** COPYING YCP DOCUMENTATION ***"
mkdir -pv ${TGTDIR}tdg >> ${BUILDLOG}
cp -arf ${DOCDIR}tdg/html/. ${TGTDIR}tdg/ >> ${BUILDLOG}
mkdir -pv ${TGTDIR}tdg/images/navig/
cp -arf ${DOCDIR}webpage/images/. ${TGTDIR}images/
cp -arf ${DOCDIR}tdg/images/. ${TGTDIR}images/
cp -arf ${DOCDIR}tdg/ui/examples ${TGTDIR}images/

echo
echo "*** COPYING STYLEGUIDE ***"
mkdir -pv ${TGTDIR}styleguide >> ${BUILDLOG}
cp -arf ${DOCDIR}styleguide/html/. ${TGTDIR}styleguide/ >> ${BUILDLOG}

echo
echo "*** COPYING CODINGRULES ***"
mkdir -pv ${TGTDIR}codingrules >> ${BUILDLOG}
cp -arf ${DOCDIR}codingrules/html/. ${TGTDIR}codingrules/ >> ${BUILDLOG}

echo
echo "*** COPYING TUTORIALS ***"
mkdir -pv ${TGTDIR}tutorials >> ${BUILDLOG}
cp -arf ${DOCDIR}tutorials/html/. ${TGTDIR}tutorials/ >> ${BUILDLOG}

# Calls a script which installs YaST-based rpm's from work to the
# ${TMPDIR} directory, builds the YCP Modules, Perl Modules and
# SCR Agents documentation and removes these installed packages
# from the ${TMPDIR} directory again
echo
echo "*** CREATING SCR/MODULES DOC ***"
cd ${DOCDIR}
echo "Running autogen/autodoc.sh ${PRODUCT} ${DOCDIR} ${TMPDIR} ${TGTDIR}"
autogen/autodoc.sh ${PRODUCT} ${DOCDIR} ${TMPDIR} ${TGTDIR} >> ${BUILDLOG}
checkforerrors

# Removes all /.svn/... directories from the www pages
# Because they shouldn't go to the final page
echo
echo "*** REMOVING .svn DIRECTORIES ***"
cd ${TGTDIR}
for file in `find | grep "\.svn"`; do rm -rf $file; done

echo
echo "*** Creating TGZ archive '"${PRODUCT}".tgz' from all the documentation ***"
cd ${TGTDIR}
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
