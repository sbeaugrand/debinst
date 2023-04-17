# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
YEAR = 2023

# cal options
#MOON = build/moon-events build/moon-themes
MOON = build/moon-events

# sundial options
#CFLAGS += -DWITH_EQUATION_OF_TIME
CFLAGS += -DWITH_AZIMUT
#CFLAGS += -DWITH_DECLINATION
GCODE_FONT = 7seg

include config.mk
ifneq ($(MAKECMDGOALS),dist-cal)
 ifneq ($(MAKECMDGOALS),dist-sundial)
  -include config-pr-symlink.mk
 endif
endif

.PHONY: all
all:
	@echo
	@echo "Usage: make cal"
	@echo "       make { portrait-cal$(YEAR).pdf }"
	@echo "       make { testAlgos | testEaster | testSun }"
	@echo "       make sundial"
	@echo "       make { portrait-sundial.pdf }"
	@echo "       make { pygcode | gcode | grbl }"
	@echo "       make azimut"
	@echo "       make { testAzimut }"
	@echo "       make dist-clean"
	@echo "       make { dist-cal | dist-sundial }"
	@echo "  [WIDTH=61.0 HEIGHT=29.7 STRAIGHT_STYLUS_LENGTH=6.5]"
	@echo

PROROOT = ..
include $(PROROOT)/makefiles/repo.mk
LDLIBS = -lm
include $(PROROOT)/makefiles/ccpp.mk

.PHONY: cal dist-cal
cal dist-cal: build cal$(YEAR).pdf

%.pdf: %.tex
	cd build && TEXINPUTS="calendar:..:"\
	 pdflatex --halt-on-error --shell-escape ../$<
	mv build/$@ .

cal$(YEAR).pdf:\
 build/sun $(MOON)\
 build/moonphase.mf build/calendar build/calendar/calend0.tex\
 build/year.tex build/lat.tex build/lon.tex build/h0.tex build/vacances$(YEAR).tex

build/moonphase.mf: $(REPO)/moonphase.mf
	@ln -sf $< $@

$(REPO)/moonphase.mf:
	@curl -o $@\
	 http://dante.ctan.org/tex-archive/fonts/moonphase/moonphase.mf

build/calendar:
	@mkdir $@

build/calendar/calend0.tex: $(REPO)/calendar.zip
	@unzip $< -d build
	@touch $@

$(REPO)/calendar.zip:
	@curl -o $@\
	 http://dante.ctan.org/tex-archive/macros/plain/contrib/calendar.zip

build/year.tex: $(MAKEFILE_LIST)
	@echo "\def\\\annee{$(YEAR)}" >$@

build/lat.tex: $(MAKEFILE_LIST)
	@echo "\def\latitude{$(LAT)}" >$@

build/lon.tex: $(MAKEFILE_LIST)
	@echo "\def\longitude{$(LON)}" >$@

build/h0.tex: $(MAKEFILE_LIST)
	@echo "\def\h0{$(H0)}" >$@

build/vacances$(YEAR).tex: vacances.sh $(MAKEFILE_LIST)
	$< $(YEAR) tex >$@

build/%: build/%.o build/algos.o
	$(LINK.c) $^ $(LDLIBS) -o $@

.PHONY: testAlgos
testAlgos: build build/testAlgos
	@build/testAlgos && echo OK

.PHONY: testEaster
testEaster:
	testPaques.sh | diff -y --suppress-common-lines testPaquesDim.ref -
	cd build && TEXINPUTS="..:" pdflatex ../testPaques.tex | grep G= |\
	 diff -y --suppress-common-lines ../testPaquesLun.ref -
	cut -d ' ' -f 1 testPaquesLun.ref >build/lun.ref
	cat testPaquesDim.ref |\
	 awk 'BEGIN { FS = "-| " } { print $$2"/"$$1"/"$$3 }' |\
	 xargs -I {} date -d "{} +1 day" +%d-%m-%Y |\
	 diff -y --suppress-common-lines build/lun.ref -

.PHONY: testSun
testSun: build build/sun
	@build/sun `date +%Y-%m-%d` $(LAT) $(LON) $(H0)

.PHONY: azimut
azimut: build/azimut
.PHONY: testAzimut
testAzimut: build/azimut
	@$< 2021-06-21 48.44728 1.48749 7.66666 | diff $@.ref -

.PHONY: sundial dist-sundial
sundial dist-sundial: build sundial.pdf

build/config.tex: $(MAKEFILE_LIST)
	@echo "\\\newlength{\sousStylaire}" >$@
	@echo -n "\setlength{\sousStylaire}" >>$@
	@echo "$(LAT) $(STRAIGHT_STYLUS_LENGTH)" |\
	 awk '{ a=$$1*3.14159/180; printf "{%fcm}\n",$$2*sin(a)/cos(a) }' >>$@
	@echo "\\\newlength{\width}" >>$@
	@echo "\setlength{\width}{$(WIDTH)cm}" >>$@
	@echo "\\\newlength{\height}" >>$@
	@echo "\setlength{\height}{$(HEIGHT)cm}" >>$@
	@echo "\\\newlength{\horizon}" >>$@
	@echo -n "\setlength{\horizon}" >>$@
	@echo "$(STYLUS_ANGLE) $(STRAIGHT_STYLUS_LENGTH)" |\
	 awk '{ a=(90-$$1)*3.14159/180; printf "{%fcm}\n",$$2*sin(a)/cos(a) }' >>$@

build/%.dat: sundial.sh build/sundial
	$< $(YEAR) $(LAT) $(LON)\
	 $(STRAIGHT_STYLUS_LENGTH) $(GNOMONIC_DECLINATION) $(STYLUS_ANGLE) $@

sundial.pdf sundialTool1.pdf pysundialTool1.ngc: build/config.tex\
 build/hiv07.dat build/pri07.dat build/ete07.dat build/aut07.dat\
 build/hiv08.dat build/pri08.dat build/ete08.dat build/aut08.dat\
 build/hiv09.dat build/pri09.dat build/ete09.dat build/aut09.dat\
 build/hiv10.dat build/pri10.dat build/ete10.dat build/aut10.dat\
 build/hiv11.dat build/pri11.dat build/ete11.dat build/aut11.dat\
 build/hiv12.dat build/pri12.dat build/ete12.dat build/aut12.dat\
 build/hiv13.dat build/pri13.dat build/ete13.dat build/aut13.dat\
 build/hiv14.dat build/pri14.dat build/ete14.dat build/aut14.dat\
 build/hiv15.dat build/pri15.dat build/ete15.dat build/aut15.dat\
 build/hiv16.dat build/pri16.dat build/ete16.dat build/aut16.dat\
 build/hiv17.dat build/pri17.dat build/ete17.dat build/aut17.dat

sundial.pdf sundialTool2.pdf pysundialTool2.ngc: build/config.tex\
 build/hiv07_5.dat build/pri07_5.dat build/ete07_5.dat build/aut07_5.dat\
 build/hiv08_5.dat build/pri08_5.dat build/ete08_5.dat build/aut08_5.dat\
 build/hiv09_5.dat build/pri09_5.dat build/ete09_5.dat build/aut09_5.dat\
 build/hiv10_5.dat build/pri10_5.dat build/ete10_5.dat build/aut10_5.dat\
 build/hiv11_5.dat build/pri11_5.dat build/ete11_5.dat build/aut11_5.dat\
 build/hiv12_5.dat build/pri12_5.dat build/ete12_5.dat build/aut12_5.dat\
 build/hiv13_5.dat build/pri13_5.dat build/ete13_5.dat build/aut13_5.dat\
 build/hiv14_5.dat build/pri14_5.dat build/ete14_5.dat build/aut14_5.dat\
 build/hiv15_5.dat build/pri15_5.dat build/ete15_5.dat build/aut15_5.dat\
 build/hiv16_5.dat build/pri16_5.dat build/ete16_5.dat build/aut16_5.dat

.PHONY: pygcode
pygcode: pysundialTool1.ngc pysundialTool2.ngc
pysundialTool1.ngc: gcode.py
	@$< -f $(GCODE_FONT) -t 1 >$@
pysundialTool2.ngc: gcode.py
	@$< -f $(GCODE_FONT) -t 2 >$@

.PHONY: gcode grbl
gcode: sundialTool1.ngc sundialTool2.ngc
grbl: grbl-sundialTool1.ngc grbl-sundialTool2.ngc
sundialTool1.ngc grbl-sundialTool1.ngc: sundialTool1.pdf
	@$(MAKE) --no-print-directory -f grbl.mk $@ PROJECT=sundialTool1
sundialTool2.ngc grbl-sundialTool2.ngc: sundialTool2.pdf
	@$(MAKE) --no-print-directory -f grbl.mk $@ PROJECT=sundialTool2

portrait-%.pdf: %.pdf
	pdfjam -q --angle 90 -o $@ $<

.PHONY: dist-clean
dist-clean:
	@$(RM) *.pdf build/*.tex build/*.dat build/moon-*

PROJECT = cal
TARDEPEND +=\
 gcodefonts/*.py\
 gcodefonts/Makefile\
 bin/pdftogcode.sh\
 bin/gcode2grbl.awk\
 bin/grblsimplify.sh\
 makefiles/gcode.mk
include $(PROROOT)/makefiles/tar.mk
