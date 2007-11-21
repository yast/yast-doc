

SOURCEDIR=../../../source
sections = $(wildcard ../../../source/yast2/library/packages/doc/*-section.xml)
sections+= $(wildcard ../../../source/yast2/library/commandline/doc/*-section.xml)
sections+= $(wildcard ../../../source/yast2/library/runlevel/doc/*-section.xml)
sections+= $(wildcard ../../../source/yast2/doc/popups.xml)
references = $(wildcard ../../../source/yast2/library/log/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/library/desktop/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/library/cwm/doc/cwm.xml)
references+= $(wildcard ../../../source/yast2/library/runlevel/doc/*-section.xml)
references+= $(wildcard ../../../source/yast2/library/commandline/doc/*-section.xml)
references+= $(wildcard ../../../source/yast2/library/cron/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/library/system/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/library/network/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/library/packages/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/library/wizard/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/library/sequencer/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/library/types/doc/autodocs/*.xml)
references+= $(wildcard ../../../source/yast2/doc/autodocs/*.xml)
SCREENSHHOTDIR=../../../source/yast2/doc/screenshots


all-local: xml screenshots
	
xml:  $(sections) $(references)
	@echo -n > entities
	@for ref in $?;\
	 do \
	    echo $$ref;\
	    test -s $$ref && xmllint --xinclude --noent --dropdtd -o `basename $$ref`  $$ref;\
	    ent=`basename $$ref .xml`;\
	    if [ $$ent != "ycpdoc" ]; then \
		test -s $$ref && echo "<!ENTITY $$ent   SYSTEM \"`basename $$ref`\">" >> entities;\
	    fi \
	 done

screenshots:
	cp -a $(SCREENSHHOTDIR) .


CLEANFILES= *.xml entities
