#!/bin/bash

# Script for building YaST documentation from SVN
# Lukas Ocilka <locilka@suse.cz>

# where available products are located
SOURCES=$1 # /work/CDs/all/, /media/SLE11-Media1, ...

# name from ${SOURCES}
# full-10.0-i386, full-10.0-x86_64, full-9.3-i386 etc...
PRODUCT=$2

# /yast/doc/SL10.1 for product full-10.1-i386
SEARCHPATH=$3

MAKE_PARAMS=$4

SEARCHDOMAIN="forgeftp.novell.com"

if [ "${PRODUCT}" == "" ] || [ "$SEARCHPATH" == "" ] || [ "${SOURCES}" == "" ]; then
    echo
    echo "Usage: ./_build-www.sh product-basedir product-in-basedir search-path [make params]"
    echo
    echo "Examples:"
    echo "  # With access to the current NFS /work directory containing the latest RPMs"
    echo "  ./_build-www.sh /work/CDs/all/ full-10.1-i386 /yast/doc/SL10.1 '-j 10'"
    echo "  # Using the locally mounted Installation DVD"
    echo "  ./_build-www.sh /media/SLE11-DVD/ suse SLES11"
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
	echo "There were some errors... exiting... current dir: "`pwd`
	exit 42;
    fi
}

# @param1: which spec file to check, if not defined, the default one (all available)
#          is used...
function CheckAndInstallPackages () {
    SPECFILE="yast2*.spec.in"
    if [ -z "$1" ]; then
	SPECFILE = $1
    fi

    CURRENTDIR=`pwd`
    echo "Extracting required packages from: "${CURRENTDIR}"/"${SPECFILE}
    echo "Extracting required packages from: "${CURRENTDIR}"/"${SPECFILE} >> ${BUILDLOG}

    # Which packages are needed
    NEEDED_PACKAGES=`grep "^BuildRequires" ${SPECFILE} | sed 's/BuildRequires:[ \t]\+//' | sed s'/.*\.spec\.in://'`
    rpm -q $NEEDED_PACKAGES || zypper in $NEEDED_PACKAGES || (echo "exiting (${CURRENTDIR})..." && exit 42)
    checkforerrors
}

echo "Building YaST documentation...
------------------------------" > ${BUILDLOG}

echo "Additional make params: "${MAKE_PARAMS} >> ${BUILDLOG}

echo
echo "*** Backing up www directory ***"
echo "| Current directory: "`pwd`
rm -rf ${TGTDIR}../www.backup
mv -fv ${TGTDIR} ${TGTDIR}../www.backup

echo
echo "*** Checking for installed packages... ***"
NEEDED_PACKAGES="docbook2x
    docbook-dsssl-stylesheets
    docbook-xml-website
    docbook-xsl-stylesheets
    docbook-toys
    docbook-utils
    docbook_3
    docbook_4
    perl
    tar
    gzip
    make
    gettext-tools
    gettext-runtime
    fop
    yast2-devtools"
echo "Calling zypper install"

rpm -q $NEEDED_PACKAGES || zypper in $NEEDED_PACKAGES || (echo "1 exiting..." && exit 42)
checkforerrors

# This part removes all known .../html/ directories
# with the previous output
echo
echo "*** REMOVING ALREADY BUILT DOCUMENTATION ***"
echo "*** REMOVING ALREADY BUILT DOCUMENTATION ***" >> ${BUILDLOG} 2 >> ${BUILDLOG}
cd ${DOCDIR}
echo "| Current directory: "`pwd`
rm -rf ${DOCDIR}tdg/html >> ${BUILDLOG} 2 >> ${BUILDLOG}
rm -rf ${DOCDIR}faq/html >> ${BUILDLOG} 2 >> ${BUILDLOG}
rm -rf ${DOCDIR}webpage/html >> ${BUILDLOG} 2 >> ${BUILDLOG}
rm -rf ${DOCDIR}modules/html >> ${BUILDLOG} 2 >> ${BUILDLOG}
rm -rf ${DOCDIR}perlmodules/html >> ${BUILDLOG} 2 >> ${BUILDLOG}
rm -rf ${DOCDIR}scr/html >> ${BUILDLOG} 2 >> ${BUILDLOG}
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
make -f Makefile.cvs >> ${BUILDLOG} 2>>${BUILDLOG}

# Cleans up the built HTML pages
echo
echo "*** CLEANING ${TGTDIR} ***"
echo "*** CLEANING ${TGTDIR} ***" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "| Current directory: "`pwd`
rm -rf ${TGTDIR} >> ${BUILDLOG} 2>>${BUILDLOG}
mkdir -pv ${TGTDIR} >> ${BUILDLOG} 2>>${BUILDLOG}

# Prepares source/core
echo
echo "*** CREATING ... in source/core"
echo "*** CREATING ... in source/core" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${SRCDIR}

cd core
echo "| Current directory: "`pwd`

CheckAndInstallPackages

make -f Makefile.cvs  >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG} 2>>${BUILDLOG}

# Creates XML documentation from libyui source
echo
echo "*** CREATING XML SOURCES IN source/libyui/doc ***"
echo "*** CREATING XML SOURCES IN source/libyui/doc ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${SRCDIR}
cd libyui



echo "| Current directory: "`pwd`
make -f Makefile.cvs  >> ${BUILDLOG} 2>>${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "2 exiting..." && exit 42)
checkforerrors

# Creates XML from ycp-ui-bindings
echo
echo "*** CREATING XML SOURCES IN ycp-ui-bindings ***"
echo "*** CREATING XML SOURCES IN ycp-ui-bindings ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${SRCDIR}
cd ycp-ui-bindings

CheckAndInstallPackages

echo "| Current directory: "`pwd`
# because 'doc' is missing there
cp --force SUBDIRS SUBDIRS.doc-build-backup
sed 's/\(.\+\)/\1 doc/' SUBDIRS.doc-build-backup > SUBDIRS
make -f Makefile.cvs >> ${BUILDLOG} 2>>${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "2 exiting..." && exit 42)
# reverting
mv --force SUBDIRS.doc-build-backup SUBDIRS
checkforerrors

# Creates XML documentation from yast2
echo
echo "*** CREATING XML SOURCES IN source/yast2 ***"
echo "*** CREATING XML SOURCES IN source/yast2 ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${SRCDIR}
cd yast2

CheckAndInstallPackages

echo "| Current directory: "`pwd`
make -f Makefile.cvs >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
# not needed for docu
# make ${MAKE_PARAMS} >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "2 exiting..." && exit 42)
checkforerrors

# Creates XML documentation from installation
echo
echo "*** CREATING XML SOURCES IN source/installation ***"
echo "*** CREATING XML SOURCES IN source/installation ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${SRCDIR}
cd installation

CheckAndInstallPackages

echo "| Current directory: "`pwd`
make -f Makefile.cvs >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "3 exiting..." && exit 42)
checkforerrors

# Creates XML documentation from wfm/doc
echo
echo "*** CREATING XML SOURCES IN source/core/wfm/doc ***"
echo "*** CREATING XML SOURCES IN source/core/wfm/doc ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${SRCDIR}
cd core/wfm/doc
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
make ${MAKE_PARAMS} >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "4 exiting..." && exit 42)

# Creates UI builtins
cd ${SRCDIR}
cd core/libycp/doc
echo "| Current directory: "`pwd`
make clean  >> ${BUILDLOG} 2>>${BUILDLOG}
rm -rf html
make ${MAKE_PARAMS} >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "5 exiting..." && exit 42)
checkforerrors

# Creating pkg-bindings
cd ${SRCDIR}
cd pkg-bindings

CheckAndInstallPackages

make -f Makefile.cvs >> ${BUILDLOG} 2>>${BUILDLOG}
cd doc
echo "| Current directory: "`pwd`
rm -rf html >> ${BUILDLOG} 2>>${BUILDLOG}
make >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors

# Checks the main doc directory
# Builds the basic html doc
echo
echo "*** PREPARING ENVIRONMENT ***"
echo "*** PREPARING ENVIRONMENT ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${DOCDIR}
echo "| Current directory: "`pwd`
make -f Makefile.cvs >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
echo "*** CLEANUP ***" >> ${BUILDLOG} 2>>${BUILDLOG}
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
echo "*** BUILDING ***" >> ${BUILDLOG} 2>>${BUILDLOG}
make >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "6 exiting..." && exit 42)
checkforerrors

# Builds the main menu with index and faq
echo
echo "*** BUILDING MAIN MENU ***"
echo "*** BUILDING MAIN MENU ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${DOCDIR}
cd webpage
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
rm -rf html >> ${BUILDLOG} 2>>${BUILDLOG}
# for the search form
export SEARCHDOMAIN=${SEARCHDOMAIN}; export SEARCHPATH=${SEARCHPATH}; make >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "7 exiting..." && exit 42)
checkforerrors

# Builds autoinstallation docu in sources
echo
echo "*** BUILDING AUTOYAST DOCUMENTATION ***"
echo "*** BUILDING AUTOYAST DOCUMENTATION ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${SRCDIR}autoinstallation
echo "| Current directory: "`pwd`
make -f Makefile.cvs >> ${BUILDLOG} 2>>${BUILDLOG}
make clean  >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "8 exiting..." && exit 42)
checkforerrors

# Builds styleguide documentation
echo
echo "*** BUILDING STYLEGUIDE DOCUMENTATION ***"
echo "*** BUILDING STYLEGUIDE DOCUMENTATION ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${DOCDIR}styleguide
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "9 exiting..." && exit 42)
checkforerrors

# Builds codingrules documentation
echo
echo "*** BUILDING CODINGRULES DOCUMENTATION ***"
echo "*** BUILDING CODINGRULES DOCUMENTATION ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${DOCDIR}codingrules
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
make >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "10 exiting..." && exit 42)
checkforerrors

# Builds tutorials
echo
echo "*** BUILDING TUTORIALS ***"
echo "*** BUILDING TUTORIALS ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${DOCDIR}tutorials
echo "| Current directory: "`pwd`
make clean >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
make html >> ${BUILDLOG} 2>>${BUILDLOG} || (echo "11 exiting..." && exit 42)
checkforerrors

# BUILDING -onefile documents
cd ${DOCDIR}tdg
echo "Creating -onefile documentation in "`pwd`
make html-onefile >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors

echo
echo "*** COPYING MAIN MENU ***"
echo "*** COPYING MAIN MENU ***" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "| Current directory: "`pwd`
cp -arf ${DOCDIR}webpage/html/. ${TGTDIR} >> ${BUILDLOG} 2>>${BUILDLOG}

echo
echo "*** COPYING AUTOINSTALLATION ***"
echo "*** COPYING AUTOINSTALLATION ***" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}autoinstall >> ${BUILDLOG} 2>>${BUILDLOG}
cp -arf ${SRCDIR}autoinstallation/doc/html/. ${TGTDIR}autoinstall/ >> ${BUILDLOG} 2>>${BUILDLOG}

echo
echo "*** COPYING YCP DOCUMENTATION ***"
echo "*** COPYING YCP DOCUMENTATION ***" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}tdg >> ${BUILDLOG} 2>>${BUILDLOG}
cp -arf ${DOCDIR}tdg/html/. ${TGTDIR}tdg/ >> ${BUILDLOG} 2>>${BUILDLOG}
mkdir -pv ${TGTDIR}tdg/images/navig/
cp -arf ${DOCDIR}webpage/images/. ${TGTDIR}images/
cp -arf ${DOCDIR}tdg/images/. ${TGTDIR}images/
cp -arf ${DOCDIR}tdg/ui/examples ${TGTDIR}images/

echo
echo "*** COPYING STYLEGUIDE ***"
echo "*** COPYING STYLEGUIDE ***" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}styleguide >> ${BUILDLOG} 2>>${BUILDLOG}
cp -arf ${DOCDIR}styleguide/html/. ${TGTDIR}styleguide/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors

echo
echo "*** COPYING CODINGRULES ***"
echo "*** COPYING CODINGRULES ***" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}codingrules >> ${BUILDLOG} 2>>${BUILDLOG}
cp -arf ${DOCDIR}codingrules/html/. ${TGTDIR}codingrules/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors

echo
echo "*** COPYING TUTORIALS ***"
echo "*** COPYING TUTORIALS ***" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}tutorials >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -arf ${DOCDIR}tutorials/html/. ${TGTDIR}tutorials/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors

# Calls a script which installs YaST-based rpm's from work to the
# ${TMPDIR} directory, builds the YCP Modules, Perl Modules and
# SCR Agents documentation and removes these installed packages
# from the ${TMPDIR} directory again
echo
echo "*** CREATING SCR/MODULES DOC ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${DOCDIR}
echo "| Current directory: "`pwd`
echo "Running autogen/autodoc.sh ${PRODUCT} ${DOCDIR} ${TMPDIR} ${TGTDIR} ${SOURCES}"
echo "Running autogen/autodoc.sh ${PRODUCT} ${DOCDIR} ${TMPDIR} ${TGTDIR} ${SOURCES}" >> ${BUILDLOG} 2>>${BUILDLOG}
autogen/autodoc.sh ${PRODUCT} ${DOCDIR} ${TMPDIR} ${TGTDIR} ${SOURCES} >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors

# Removes all /.svn/... directories from the www pages
# Because they shouldn't go to the final page
echo
echo "*** REMOVING .svn DIRECTORIES ***"
echo "*** REMOVING .svn DIRECTORIES ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${TGTDIR}
echo "| Current directory: "`pwd`
for file in `find | grep "\.svn"`; do rm -rf $file; done

# Copying built docu into the directory for the final www pages
echo "*** COPYING -onefile DOCUMENTATION ***"
echo "*** COPYING -onefile DOCUMENTATION ***" >> ${BUILDLOG} 2>>${BUILDLOG}
mkdir -p cd ${TGTDIR}/onefile >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -afv ${DOCDIR}modules/modules-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -afv ${DOCDIR}perlmodules/perlmodules-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -afv ${DOCDIR}scr/scr-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -afv ${DOCDIR}styleguide/style-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -afv ${DOCDIR}tdg/yast-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -afv ${DOCDIR}tutorials/tutorial-onefile.html ${TGTDIR}onefile/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors

echo "*** COPYING pkg-bindings ***"
echo "*** COPYING pkg-bindings ***" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "| Current directory: "`pwd`
mkdir -pv ${TGTDIR}/pkg-bindings >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -arfv ${SRCDIR}/pkg-bindings/doc/html/*.html ${TGTDIR}/pkg-bindings/ >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors
cp -afv ${TGTDIR}/style/default.css ${TGTDIR}/pkg-bindings/yast2docs.css >> ${BUILDLOG} 2>>${BUILDLOG}
checkforerrors

echo
echo "*** Creating TGZ archive '"${PRODUCT}".tgz' from all the documentation ***"
echo "*** Creating TGZ archive '"${PRODUCT}".tgz' from all the documentation ***" >> ${BUILDLOG} 2>>${BUILDLOG}
cd ${TGTDIR}
echo "| Current directory: "`pwd`
tar -zcf yast-documentation.tgz * >> ${BUILDLOG} 2>>${BUILDLOG}
mkdir -pv ${TGTDIR}download/ >> ${BUILDLOG} 2>>${BUILDLOG}
mv -fv yast-documentation.tgz ${TGTDIR}download/ >> ${BUILDLOG} 2>>${BUILDLOG}

echo
echo "*** DONE ***"
echo
echo "==========================================================================="
echo "Built webpage can be found in the ${TGTDIR} directory"
echo "Built webpage can be found in the ${TGTDIR} directory" >> ${BUILDLOG} 2>>${BUILDLOG}
echo "==========================================================================="
echo
