

SOURCEDIR=../../../source
sections = $(wildcard ../../../source/pkg-bindings/doc/*-section.xml)
references = $(wildcard ../../../source/pkg-bindings/doc/Pkg*.xml)


all-local: xml 
	
xml:  $(sections) $(references)
	@echo " " > entities
	@for ref in $?;\
	 do \
	    echo $$ref;\
	    xmllint --xinclude --noent --dropdtd -o `basename $$ref`  $$ref;\
	    ent=`basename $$ref .xml`;\
	    if [ $$ent != "ycpdoc" ]; then \
		echo "<!ENTITY $$ent   SYSTEM \"`basename $$ref`\">" >> entities;\
	    fi \
	 done


CLEANFILES= *.xml entities
