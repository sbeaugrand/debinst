# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = chebyshev
PROROOT = ../..
PROPATH = latex
CSVTRANSPOSE = $(HOME)/install/debinst/install-12-latex/csvtranspose.sh
DST_EXT = .data# ngspice revision 30

.PHONY: all
all: $(PROJECT).pdf

$(SRCDIR)/%Simulation.csv: $(SRCDIR)/%.csv
	$(CSVTRANSPOSE) $< $@

$(PROJECT).pdf: chebyshev.tex build\
 chebyshev.m\
 chebyshev.py\
 build/chebyshevARRL1981.dat\
 build/chebyshevARRL1981.a80\
 build/chebyshevARRL1990.dat\
 build/chebyshevARRL1990.a80\
 build/chebyshev6t80m290o.dat\
 build/chebyshev6t80m290o.a80\
 build/chebyshev6t80m50o.dat\
 build/chebyshev6t80m50o.a80\
 build/chebyshev5t80m50o.dat\
 build/chebyshev5t80m50o.a80\
 build/chebyshev5t80m560p.dat\
 build/chebyshev5t80m560p.a80\
 build/chebyshev5t80m680p.dat\
 build/chebyshev5t80m680p.a80\
 build/chebyshev5t80m820p.dat\
 build/chebyshev5t80m820p.a80\
 build/chebyshev5t80m1000p.dat\
 build/chebyshev5t80m1000p.a80\
 build/chebyshev5t80m1200p.dat\
 build/chebyshev5t80m1200p.a80\
 build/chebyshev5p80m2700p.dat\
 build/chebyshev5p80m2700p.a80\
 build/chebyshev5p80m2200p.dat\
 build/chebyshev5p80m2200p.a80\
 build/chebyshev5p80m1800p.dat\
 build/chebyshev5p80m1800p.a80\
 build/chebyshev5p80m1500p.dat\
 build/chebyshev5p80m1500p.a80\
 build/chebyshev5p80m1200p.dat\
 build/chebyshev5p80m1200p.a80\
 build/chebyshev5p40m470p.dat\
 build/chebyshev5p40m470p.a40\
 build/chebyshev3t40mPixie.dat\
 build/chebyshev3t40mPixie.a40\
 build/chebyshev3p80mPixie.dat\
 build/chebyshev3p80mPixie.a80\
 build/chebyshev5p80mBingo.dat\
 build/chebyshev5p80mBingo.a80\
 build/chebyshev5p80mLibra.dat\
 build/chebyshev5p80mLibra.a80\
 build/cauer935p.dat\
 build/cauer935p.a80\
 build/cauer1300p.dat\
 build/cauer1300p.a80\
 build/cauer1200p.dat\
 build/cauer1200p.a80\

	pdflatex --halt-on-error $<
	@$(RM) $(PROJECT).aux $(PROJECT).log

build:
	@mkdir $@

%.dat: %.data
	@cat $< |\
	 awk 'BEGIN { print "Time V/sortiemag" } { print $$1/1e6" "$$2 }' >$@

%.data: %.net
	@ngspice -b -r dummy $<

%.a80: %.data
	octave --eval "\
	 [x, y] = textread('$<');\
	 f = @(xi) interp1(x, y, xi);\
	 printf('Fondamentale: %.1f dbV\\\\\\', f(3579000));\
	 printf('Harmonique: %.1f dbV\\\\\\', f(3579000 * 2));\
	" >$@

%.a40: %.data
	octave --eval "\
	 [x, y] = textread('$<');\
	 f = @(xi) interp1(x, y, xi);\
	 printf('Fondamentale: %.1f dbV\\\\\\', f(7000000));\
	 printf('Harmonique: %.1f dbV\\\\\\', f(7000000 * 2));\
	" >$@

build/chebyshev5t80m50o.in : build/chebyshev5t80m50o.dat
	@sed 1d $< >$@

chebyshev5t80m.net:
chebyshev6t80m.net:

build/chebyshevARRL1981.net: chebyshev5t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/820p/'\
	 -e 's/<C18>/820p/'\
	 -e "s/<L3>/`echo 29 | awk '{ print 49 * ($$1 / 100) ^ 2 }'`u/"\
	 -e "s/<L4>/`echo 35 | awk '{ print 49 * ($$1 / 100) ^ 2 }'`u/"\
	 -e "s/<L5>/`echo 29 | awk '{ print 49 * ($$1 / 100) ^ 2 }'`u/"\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshevARRL1981$(DST_EXT)/'\
	 | cat >$@

build/chebyshevARRL1990.net: chebyshev5t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/820p/'\
	 -e 's/<C18>/820p/'\
	 -e "s/<L3>/`echo 25 | awk '{ print 49 * ($$1 / 100) ^ 2 }'`u/"\
	 -e "s/<L4>/`echo 32 | awk '{ print 49 * ($$1 / 100) ^ 2 }'`u/"\
	 -e "s/<L5>/`echo 25 | awk '{ print 49 * ($$1 / 100) ^ 2 }'`u/"\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshevARRL1990$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5t80m50o.net: chebyshev5t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/638p/'\
	 -e 's/<C18>/638p/'\
	 -e 's/<L3>/7.29u/'\
	 -e 's/<L4>/9.50u/'\
	 -e 's/<L5>/7.29u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5t80m50o$(DST_EXT)/'\
	 | cat >$@

build/chebyshev6t80m50o.net: chebyshev6t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/643.73428p/'\
	 -e 's/<C18>/664.21197p/'\
	 -e 's/<C20>/505.35345p/'\
	 -e 's/<L3>/7.339u/'\
	 -e 's/<L4>/9.646u/'\
	 -e 's/<L5>/9.348u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev6t80m50o$(DST_EXT)/'\
	 | cat >$@

build/chebyshev6t80m290o.net: chebyshev6t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/643.73428p/'\
	 -e 's/<C18>/664.21197p/'\
	 -e 's/<C20>/505.35345p/'\
	 -e 's/<L3>/7.339u/'\
	 -e 's/<L4>/9.646u/'\
	 -e 's/<L5>/9.348u/'\
	 -e 's/<R2>/290.474/'\
	 -e "s/<VJ1>/`echo 50 290.474 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev6t80m290o$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5t80m560p.net: chebyshev5t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/560p/'\
	 -e 's/<C18>/560p/'\
	 -e 's/<L3>/8.49u/'\
	 -e 's/<L4>/10.92u/'\
	 -e 's/<L5>/8.49u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5t80m560p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5t80m680p.net: chebyshev5t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/680p/'\
	 -e 's/<C18>/680p/'\
	 -e 's/<L3>/6.75u/'\
	 -e 's/<L4>/8.87u/'\
	 -e 's/<L5>/6.75u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5t80m680p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5t80m820p.net: chebyshev5t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/820p/'\
	 -e 's/<C18>/820p/'\
	 -e 's/<L3>/5.27u/'\
	 -e 's/<L4>/7.17u/'\
	 -e 's/<L5>/5.27u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5t80m820p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5t80m1000p.net: chebyshev5t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/1000p/'\
	 -e 's/<C18>/1000p/'\
	 -e 's/<L3>/3.8u/'\
	 -e 's/<L4>/5.56u/'\
	 -e 's/<L5>/3.8u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5t80m1000p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5t80m1200p.net: chebyshev5t80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/1153p/'\
	 -e 's/<C18>/1153p/'\
	 -e 's/<L3>/2.09u/'\
	 -e 's/<L4>/3.83u/'\
	 -e 's/<L5>/2.09u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5t80m1200p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5p80m2700p.net: chebyshev5p80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/2700p/'\
	 -e 's/<C18>/3549p/'\
	 -e 's/<C20>/2700p/'\
	 -e 's/<L4>/1.7u/'\
	 -e 's/<L5>/1.7u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5p80m2700p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5p80m2200p.net: chebyshev5p80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/2200p/'\
	 -e 's/<C18>/2974p/'\
	 -e 's/<C20>/2200p/'\
	 -e 's/<L4>/2u/'\
	 -e 's/<L5>/2u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5p80m2200p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5p80m1800p.net: chebyshev5p80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/1800p/'\
	 -e 's/<C18>/2527p/'\
	 -e 's/<C20>/1800p/'\
	 -e 's/<L4>/2.26u/'\
	 -e 's/<L5>/2.26u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5p80m1800p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5p80m1500p.net: chebyshev5p80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/1500p/'\
	 -e 's/<C18>/2203p/'\
	 -e 's/<C20>/1500p/'\
	 -e 's/<L4>/2.52u/'\
	 -e 's/<L5>/2.52u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5p80m1500p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5p80m1200p.net: chebyshev5p80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/1200p/'\
	 -e 's/<C18>/1893p/'\
	 -e 's/<C20>/1200p/'\
	 -e 's/<L4>/2.75u/'\
	 -e 's/<L5>/2.75u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5p80m1200p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5p40m470p.net: chebyshev5p40m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/470p/'\
	 -e 's/<C18>/1000p/'\
	 -e 's/<C20>/470p/'\
	 -e 's/<L4>/1.024u/'\
	 -e 's/<L5>/1.024u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5p40m470p$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5p80mBingo.net: chebyshev5p80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/820p/'\
	 -e 's/<C18>/1500p/'\
	 -e 's/<C20>/820p/'\
	 -e 's/<L4>/2u/'\
	 -e 's/<L5>/2u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5p80mBingo$(DST_EXT)/'\
	 | cat >$@

build/chebyshev5p80mLibra.net: chebyshev5p80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/820p/'\
	 -e 's/<C18>/1500p/'\
	 -e 's/<C20>/820p/'\
	 -e 's/<L4>/2.2u/'\
	 -e 's/<L5>/2.2u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev5p80mLibra$(DST_EXT)/'\
	 | cat >$@

build/chebyshev3t40mPixie.net: chebyshev3t40m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/820p/'\
	 -e 's/<C18>/820p/'\
	 -e 's/<L4>/1.2u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev3t40mPixie$(DST_EXT)/'\
	 | cat >$@

build/chebyshev3p80mPixie.net: chebyshev3p80m.net
	@cat $< | sed\
	 -e 's/<R1>/50/'\
	 -e 's/<C17>/820p/'\
	 -e 's/<C18>/820p/'\
	 -e 's/<L4>/2.2u/'\
	 -e 's/<R2>/50/'\
	 -e "s/<VJ1>/`echo 50 50 | awk '{ print ($$1 + $$2) / $$2 }'`/"\
	 -e 's/<dst>/chebyshev3p80mPixie$(DST_EXT)/'\
	 | cat >$@

build/cauer935p.net: cauer.net
	@cat $< | sed\
	 -e 's/<L4>/2.29u/'\
	 -e 's/<L5>/1.87u/'\
	 -e 's/<C2>/99p/'\
	 -e 's/<C4>/279p/'\
	 -e 's/<C17>/935p/'\
	 -e 's/<C18>/1396p/'\
	 -e 's/<C20>/793p/'\
	 -e 's/<dst>/cauer935p$(DST_EXT)/'\
	 | cat >$@

build/cauer1300p.net: cauer.net
	@cat $< | sed\
	 -e 's/<L4>/1.5u/'\
	 -e 's/<L5>/1.3u/'\
	 -e 's/<C2>/180p/'\
	 -e 's/<C4>/390p/'\
	 -e 's/<C17>/1300p/'\
	 -e 's/<C18>/2400p/'\
	 -e 's/<C20>/1100p/'\
	 -e 's/<dst>/cauer1300p$(DST_EXT)/'\
	 | cat >$@

build/cauer1200p.net: cauer.net
	@cat $< | sed\
	 -e 's/<L4>/1.5u/'\
	 -e 's/<L5>/1.2u/'\
	 -e 's/<C2>/180p/'\
	 -e 's/<C4>/390p/'\
	 -e 's/<C17>/1200p/'\
	 -e 's/<C18>/2200p/'\
	 -e 's/<C20>/1000p/'\
	 -e 's/<dst>/cauer1200p$(DST_EXT)/'\
	 | cat >$@

include $(PROROOT)/makefiles/tar.mk
