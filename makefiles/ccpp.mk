# ---------------------------------------------------------------------------- #
## \file ccpp.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND  += makefiles/ccpp.mk
WARNINGS   ?= -Wall -Wextra -O1 -D_FORTIFY_SOURCE=2 -Wfatal-errors
CFLAGS     += $(WARNINGS)
CXXFLAGS   += $(WARNINGS)
COBJECTS   ?= $(patsubst %.c,%.o,$(wildcard *.c))
CXXOBJECTS ?= $(patsubst %.cpp,%.o,$(wildcard *.cpp))
COBJECTS   := $(addprefix build/,$(COBJECTS))
CXXOBJECTS := $(addprefix build/,$(CXXOBJECTS))
CDEP        = $(patsubst %.o,%.d,$(COBJECTS))
CXXDEP      = $(patsubst %.o,%.d,$(CXXOBJECTS))
ifeq ($(OBJECTS),)
 OBJECTS = $(COBJECTS) $(CXXOBJECTS)
else
 OBJECTS := $(subst build//,/,$(addprefix build/,$(OBJECTS)))
endif
TARGETS += "| clean | mrproper | cppcheck | dep"

.SUFFIXES:

build:
	@mkdir $@

build/%.o: %.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<

build/%.o: %.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

/%.o: /%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<

/%.o: /%.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

.PHONY: clean
clean:
	@$(RM) build/*.o build/*.d build/*.elf *~

.PHONY: mrproper
mrproper: clean
	@$(RM) -r build/

.PHONY: cppcheck
cppcheck:
	@eval cppcheck -q --enable=all\
	 `test -f cppcheck.supp && echo --suppressions-list=cppcheck.supp`\
	 --template='{id}:{file}:{line}\ \({severity}\)\ {message}'\
	 -i build -i build-*\
	 --suppress=missingIncludeSystem\
	 $(CPPCHECKINC) .

.PHONY: dep
dep:
	@for f in $(patsubst %.c,%,$(wildcard *.c)); do \
		$(CC) $(CFLAGS) -MM -MF build/$$f.d -MT build/$$f.o $$f.c; \
		cat build/$$f.d; \
	done
	@for f in $(patsubst %.cpp,%,$(wildcard *.cpp)); do \
		$(CXX) $(CXXFLAGS) -MM -MF build/$$f.d -MT build/$$f.o $$f.cpp; \
		cat build/$$f.d; \
	done

-include $(CDEP) $(CXXDEP)

ifeq ($(OBJECTS_NDEP_MAKEFILE_LIST),)
$(OBJECTS): $(MAKEFILE_LIST)
endif
