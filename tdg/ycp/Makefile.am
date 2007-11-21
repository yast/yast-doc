

SOURCEDIR=../../../source
references= $(wildcard ../../../source/core/libycp/doc/*Builtin*.xml)
references+= $(wildcard ../../../source/core/wfm/doc/Y2WFMComponent.xml)
EXAMPLEDIR=
xmlfiles := $(foreach xml,$(references),$(notdir $(xml)))

all-local: xml
	
xml:  $(sections) $(references)
	@echo " " > entities
	@for ref in $?;\
	 do \
	    echo $$ref;\
	    xmllint --xinclude --noent --dropdtd -o `basename $$ref`  $$ref;\
	    ent=`basename $$ref .xml`;\
	    echo "<!ENTITY $$ent   SYSTEM \"`basename $$ref`\">" >> entities;\
	 done


CLEANFILES=  entities $(xmlfiles)
