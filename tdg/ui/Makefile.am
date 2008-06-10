

SOURCEDIR=../../../

references=../../../ycp-ui-bindings/doc/YCP_UI.xml
references+=../../../ycp-ui-bindings/doc/YCPDialogParser.xml
references+=../../../ycp-ui-bindings/doc/events/event-builtins.xml

appendix=../../../ycp-ui-bindings/doc/YCP-UI-richtext.xml
sections=../../../ycp-ui-bindings/doc/events/event-intro.xml
sections+=../../../ycp-ui-bindings/doc/YCP-UI-layout.xml
EXAMPLEDIR=../../../ycp-ui-bindings/examples


all-local: xml examples

xml:  $(sections) $(appendix) $(references)
	@echo " " > entities
	@for ref in $?;\
	 do \
	    echo $$ref;\
	    xmllint --xinclude --noent --dropdtd -o `basename $$ref`  $$ref;\
	    ent=`basename $$ref .xml`;\
	    echo "<!ENTITY $$ent   SYSTEM \"`basename $$ref`\">" >> entities;\
	 done

examples:
	cp -a $(EXAMPLEDIR) .


CLEANFILES= *.xml entities
