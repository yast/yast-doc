

SOURCEDIR=../../../
references = ../../../core/libyui/doc/YCP_UI.xml
references+=  ../../../core/libyui/doc/YCPDialogParser.xml
references+= ../../../core/libyui/doc/events/event-builtins.xml
appendix=../../../core/libyui/doc/YCP-UI-richtext.xml
sections=../../../core/libyui/doc/events/event-intro.xml
sections+=../../../core/libyui/doc/YCP-UI-layout.xml
EXAMPLEDIR=../../../core/libyui/doc/examples


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
