# Makefile
# Author: Arun Chaganty <arunchaganty@gmail.com>
#         Kirtika Ruchandani <kirtibr@gmail.com>
#

ROOTDIR=./
include Makefile.inc

TARGETS=bin/ctm
TESTS = tests/read_corpus tests/log tests/settings

PRJNAME=ctm
VERSION=0.01
SRCFILES=include/ misc/ src/ tests/ Doxyfile Makefile README 
DISTFILES=$(TARGETS) tests/ doc/ README

CFLAGS += 
LDFLAGS += 

LIB_OBJS=obj/util.o obj/ctm-data.o \
		 obj/InferenceEngine.o obj/CollapsedBayesEngine.o

BIN_OBJS=obj/main.o
OBJS=$(LIB_OBJS) $(BIN_OBJS)

all: targets tests

targets: $(TARGETS) 

tests: ${TESTS}

bin/ctm: ${OBJS}
	if [ ! -e bin ]; then mkdir bin; fi;
	$(CC) $(LDFLAGS) $^ -o $@

# Pattern to build obj files from src files
${OBJS}: obj/%.o : src/%.cpp 
	if [ ! -e obj ]; then mkdir obj; fi;
	$(CC) $(CFLAGS) -c $^ -o $@

${TESTS}: tests/% : tests/%.cpp ${LIB_OBJS}
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

test: tests
	./test.sh

src-dist: 
	rm -rf $(PRJNAME)-src-$(VERSION)
	mkdir $(PRJNAME)-src-$(VERSION)
	cp -rf $(SRCFILES) $(PRJNAME)-src-$(VERSION)/
	tar -czf $(PRJNAME)-src-$(VERSION).tar.gz $(PRJNAME)-src-$(VERSION)/
	rm -rf $(PRJNAME)-src-$(VERSION)

bin-dist: all
	rm -rf $(PRJNAME)-$(VERSION)
	mkdir $(PRJNAME)-$(VERSION)
	cp -rf $(DISTFILES) $(PRJNAME)-$(VERSION)/
	tar -czf $(PRJNAME)-$(VERSION).tar.gz $(PRJNAME)-$(VERSION)/
	rm -r $(PRJNAME)-$(VERSION)

.PHONY: clean clean-tests doc test

doc: 
	doxygen

clean:
	rm -rf bin/*
	rm -rf lib/*
	rm -rf obj/*

clean-tests:
	rm -rf $(TESTS)
