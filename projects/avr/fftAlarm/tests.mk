# ---------------------------------------------------------------------------- #
## \file tests.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROROOT = ../..
include $(PROROOT)/makefiles/pro.mk

ifneq ($(SIGNED),)
 DSIGNED = -DSIGNED=$(SIGNED)
endif

ifeq ($(MAKECMDGOALS),$(PROJECT))
 OBJECTS = $(PROJECT).o fix_fft.o
 CFLAGS = -DF_CPU=8000000UL $(DSIGNED) -DNDEBUG -I.
 LDFLAGS = -lm
endif
ifeq ($(MAKECMDGOALS),plot)
 OBJECTS = x11Bar.o plot.o
 CXXFLAGS = -DF_CPU=8000000UL
endif
ifeq ($(MAKECMDGOALS),sinus)
 OBJECTS = sinus.o wiring_analog-sinus.o
 CFLAGS = -DF_CPU=8000000UL
 LDFLAGS = -lm
endif
ifeq ($(MAKECMDGOALS),arecord)
 ifeq ($(D),)
  $(error Device D is not set)
 endif
endif

SHELL = /bin/bash

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo "Tests"
	@echo "  make -f tests.mk plot"
	@echo
	@echo "  Test sinus"
	@echo "    make -f tests.mk clean"
	@echo "    make -f tests.mk $(PROJECT)"
	@echo "    make -f tests.mk sinus"
	@echo
	@echo "  Test arecord"
	@echo "    make -f tests.mk clean"
	@echo "    make -f tests.mk $(PROJECT) SIGNED=1"
	@echo "    make -f tests.mk arecord D=pulse_monitor  # or"
	@echo "    make -f tests.mk arecord D=plughw"
	@echo
	@echo "  Test alsabat"
	@echo "    make -f tests.mk clean"
	@echo "    make -f tests.mk $(PROJECT) SIGNED=1"
	@echo "    make -f tests.mk arecord D=pulse_monitor  # and"
	@echo "    make -f tests.mk alsabat"
	@echo

include $(PROROOT)/makefiles/ccpp.mk

ifeq ($(MAKECMDGOALS),plot)
 include $(PROROOT)/x11/x11.mk
else
 TARDEPEND += x11/*
endif
ifeq ($(MAKECMDGOALS),sinus)
 include $(PROROOT)/wiring/wiring.mk
 include $(PROROOT)/debug/debug.mk
endif

.PHONY: $(PROJECT)
$(PROJECT): build build/$(PROJECT)

build/$(PROJECT): $(OBJECTS)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

.PHONY: plot
plot: build build/plot

build/plot: $(OBJECTS)
	$(CXX) $(CFLAGS) $^ $(LDFLAGS) -o $@

.PHONY: sinus
sinus: build build/sinus
	build/sinus fps=auto 2000 | build/fftAlarm | build/plot

build/sinus: $(OBJECTS)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

.PHONY: arecord
arecord:
	arecord -D $(D) -r 9600 -f S16_LE --period-size=256 | build/fftAlarm | build/plot

.PHONY: alsabat
alsabat:
	@for ((f = 200; f <= 4000; f = f + 100)); do \
		alsabat -n 1s -F $$f; \
	done
