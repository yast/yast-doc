

SOURCEDIR=../../../source
references = ../../../source/core/libyui/doc/YUI_builtins.xml
references+=  ../../../source/core/libyui/doc/YUI_widgets.xml
references+= ../../../source/core/libyui/doc/YUI_special_widgets.xml
references+= ../../../source/core/libyui/doc/events/event-builtins.xml
appendix=../../../source/core/libyui/doc/YCP-UI-richtext.xml
sections=../../../source/core/libyui/doc/events/event-intro.xml
sections+=../../../source/core/libyui/doc/YCP-UI-layout.xml
EXAMPLEDIR=../../../source/core/libyui/doc/examples


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
