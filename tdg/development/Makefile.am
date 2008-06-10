
SOURCEDIR=../../../
sections = $(wildcard ../../../devtools/devtools/doc/*-section.xml)
sections+= $(wildcard ../../../devtools/yast2/check_ycp/doc/*-section.xml)
sections+=../../../ycp-ui-bindings/doc/macro-recorder.xml
sections+=../../../core/libycp/doc/logging.xml
sections+=desktop_files.xml
EXAMPLEDIR=


all-local: xml localxml
	
xml:  $(sections) 
	@echo " " > entities
	@for ref in $?;\
	 do \
	    echo $$ref;\
	    xmllint --loaddtd --xinclude  --noent --dropdtd -o `basename $$ref` $$ref;\
	    ent=`basename $$ref .xml`;\
	    echo "<!ENTITY $$ent   SYSTEM \"`basename $$ref`\">" >> entities;\
	 done


# Coding.xml and coding-rules.xml deprecated by
# doc/codingrules/rules.xml
localxml:
	@for f in $?;\
	do \
	    ent=`basename $$f .xml`;\
	    echo "<!ENTITY $$ent   SYSTEM \"`basename $$f`\">" >> entities;\
	done

CLEANFILES= *-section.xml entities
