

SOURCEDIR=../../../source
sections = $(wildcard ../../../source/installation/control/docs/*-section.xml)
sections+= $(wildcard ../../../source/installation/doc/proposal/proposal-API-section.xml)
sections+= $(wildcard ../../../source/installation/doc/proposal/proposal-API-reference.xml)
sections+= $(wildcard ../../../source/firstboot/doc/*-section*.xml)
references = $(wildcard ../../../source/installation/proposal/doc/*-reference.xml)
EXAMPLEDIR=


all-local: xml
	
xml: $(references) $(sections)
	@echo " " > entities
	@for ref in $?;\
	 do \
	    echo $$ref;\
	    xmllint --xinclude --noent --dropdtd -o `basename $$ref`  $$ref;\
	    ent=`basename $$ref .xml`;\
	    echo "<!ENTITY $$ent   SYSTEM \"`basename $$ref`\">" >> entities;\
	 done


CLEANFILES= *.xml entities
