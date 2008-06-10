#!/bin/bash

# tmp directory for installing rpms
TMPROOT=$3
# directory for output of html docu
OUTPUT=$4
# source directory of scripts and xslt
# or just directory with subdirectories 'scr' and 'modules' including also building scripts...
DOCSVNDIR=$2
# directory of products / rpms
# e.g., /work/CDs/all/
SOURCES=$5

PRODUCT=$1

### TESTING >>>

if [ "${PRODUCT}" == "" ] || [ "${TMPROOT}" == "" ] || [ "${OUTPUT}" == "" ] || [ "${DOCSVNDIR}" == "" ] || [ "${SOURCES}" == "" ]; then
    echo
    echo "Usage:   ./autodoc.sh product-name /doc_directory/ /tmp-directory/ /output-directory/ /rpms-basedir/"
    echo
    echo "List of available products: "
    for prodname in `ls -1 ${SOURCES}`; do
	echo "	"${prodname}
    done
    echo
    exit 1;
fi

if [ ! -e ${SOURCES} ]; then
    echo "Directory ${SOURCES} does not exist"
    exit 1;
fi

TMPROOT="${TMPROOT}/${PRODUCT}"
SOURCES="${SOURCES}/${PRODUCT}/suse"

if [ ! -e ${SOURCES} ]; then
    echo "Directory ${SOURCES} does not exist"
    exit 1;
fi

rm -rf ${TMPROOT}
mkdir -pv ${TMPROOT}

rm -rf ${OUTPUT}/modules/
rm -rf ${OUTPUT}/perlmodules/
rm -rf ${OUTPUT}/scr/

mkdir -pv ${OUTPUT}

if [ ! -e ${TMPROOT} ]; then
    echo "Directory ${TMPROOT} does not exist"
    exit 1;
fi

if [ ! -e ${OUTPUT} ]; then
    echo "Directory ${OUTPUT} does not exist"
    exit 1;
fi

### TESTING <<<

### INSTALLING to the tmp root
echo "Installing all YaST modules from '${SOURCES}' to the temporary directory '${TMPROOT}'"
cd ${SOURCES}
mkdir -p ${TMPROOT}/var/lib/rpm/
rpm --initdb --root ${TMPROOT}
rpm -Uvh --noscripts --ignorearch --force --root ${TMPROOT} --nodeps `find -iname yast2*.rpm; find -iname autoyast*.rpm`

### Creating YaST Modules
echo "Creating documentation of YaST Modules"
cd ${DOCSVNDIR}/modules
./modules_doc.sh ${TMPROOT}

### Moving YaST Modules
echo "Moving generated Modules to the ${OUTPUT}/modules directory"
mv -fv ./html/ ${OUTPUT}/modules
mv -fv ./style ${OUTPUT}
mv -fv ./images ${OUTPUT}

### Creating SCR Agents
echo "Creating documentation of SCR Agents"
cd ${DOCSVNDIR}/scr
./scr_doc.sh ${TMPROOT}

### Moving SCR Agents
echo "Moving generated SCR Agents to the ${OUTPUT}/scr directory"
mv -fv ./html/ ${OUTPUT}/scr
mv -fv ./style ${OUTPUT}
mv -fv ./images ${OUTPUT}

### Creating Perl Modules
echo "Creating documentation of Perl Modules"
cd ${DOCSVNDIR}/perlmodules
./perl_doc.sh ${TMPROOT}

### Moving Perl Modules
echo "Moving generated Perl Modules to the ${OUTPUT}/modules directory"
mv -fv ./html/ ${OUTPUT}/perlmodules
mv -fv ./style ${OUTPUT}
mv -fv ./images ${OUTPUT}

### Backing up
tar --ignore-failed-read -zcf ${DOCSVNDIR}/autogen/backup-of-generated-docu.tgz \
    ${DOCSVNDIR}/modules/style ${DOCSVNDIR}/modules/images \
    ${DOCSVNDIR}/modules/ycpdoc.xml ${DOCSVNDIR}/modules/index.xml \
    ${DOCSVNDIR}/scr/style ${DOCSVNDIR}/scr/images \
    ${DOCSVNDIR}/scr/output.xml ${DOCSVNDIR}/scr/index.xml \
    ${DOCSVNDIR}/perlmodules/conversion_output.xml ${DOCSVNDIR}/perlmodules/index.xml

### Cleaning
rm -rf \
    ${DOCSVNDIR}/modules/style ${DOCSVNDIR}/modules/images \
    ${DOCSVNDIR}/modules/ycpdoc.xml ${DOCSVNDIR}/modules/index.xml \
    ${DOCSVNDIR}/scr/style ${DOCSVNDIR}/scr/images \
    ${DOCSVNDIR}/scr/output.xml ${DOCSVNDIR}/scr/index.xml \
    ${DOCSVNDIR}/perlmodules/conversion_output.xml ${DOCSVNDIR}/perlmodules/index.html

### Fixing hardcoded paths in SCR agents because of TMPROOTS
cd ${OUTPUT}/scr
for FILE in `find | grep "\.html"`; do
    echo "Processing file " ${FILE}
    sed 's#'${TMPROOT}'##g' ${FILE} > .tmpfile
    mv -f .tmpfile ${FILE}
done

exit 0;
