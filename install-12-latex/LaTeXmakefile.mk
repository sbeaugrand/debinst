# ---------------------------------------------------------------------------- #
## \file LaTeXmakefile.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
#
# Utilisation :
#
# - mettre dans un Makefile, par exemple :
#
# PROJET=p1
# include ../LaTeXmakefile.mk
#
# - generer les dependances avec "make dep"
#
# - compiler le projet avec "make p1"
#
# - compiler les sections modifiees avec "make"
#
# Les sections sont donc dans des fichiers separes (par exemple src/s1.tex)
# et leurs compilations separees se font avec d'autres fichiers dont le nom
# commence par sec/section-.
# Par exemple sec/section-s1.tex pourrait ressembler a :
#
# \documentclass{cls/section}
# \begin{document}
# \input s1
# \end{document}
#
# Et le fichier du projet pourrait ressembler a :
#
# \documentclass{cls/livret}
# \begin{document}
# \input s1
# \newpage
# \input s2
# \newpage
# \input s3
# \end{document}
#
# Remarque : ces exemples sont adaptes a la production de livrets A5 sans
# changement d'echelle. (Utilisation du fichier cls/livret.cls et "pdfbook".)
#
# Si une dependance est modifiee (ajout ou suppression d'un \input,
# \includegraphics de pdf, ou \verbatiminput), les regenerer avec "make dep".
# Ne regenerer qu'un seul fichier de dependance :
# make dep DEP=dep/src/s1.dep
# make dep DEP=dep/sec/section-s1.tex
#
# - verifier l'orthographe avec "make spell"
#
# Ceci fonctionne pour tous les fichiers ayant un fichier .dic correspondant
# dans le repertoire dic. Pour ajouter une verification sur un nouveau fichier,
# faire par exemple "touch dic/s1.dic && touch src/s1.tex". Normalement les
# fichiers sec/section-*.tex n'ont pas besoin de fichiers .dic associes.
#
# - produire un extrait  : make pdf/extrait-<pdf> P=2,3,4,1
#
# - produire un livret   : make pdf/livret-<pdf>
#
# - produire un portrait : make pdf/portrait-<pdf>
#
# ---------------------------------------------------------------------------- #
PDFDIR  = pdf
SRCDIR  = src/
SECDIR  = sec/
MAKEDOC = @pdflatex --halt-on-error -output-directory $(PDFDIR) $<
PURGE   = @$(RM) -f $(PDFDIR)/*.aux $(PDFDIR)/*.log $(SRCDIR)*~ $(SECDIR)*~
DEP = $(patsubst %.tex,dep/%.dep,$(wildcard */*.tex))
OBJ = $(patsubst $(SECDIR)%.tex,$(PDFDIR)/%.pdf,\
      $(wildcard $(SECDIR)section-*.tex))
DIC = $(wildcard dic/*.dic)

.SUFFIXES:

.PHONY: all
all: $(PDFDIR) $(OBJ)
	$(PURGE)

$(PDFDIR) dep/$(SRCDIR) dep/$(SECDIR) dic:
	@mkdir -p $@

$(OBJ): $(PDFDIR)/section-%.pdf: $(SECDIR)section-%.tex
	$(MAKEDOC)

.PHONY: $(PROJET)
$(PROJET): $(PDFDIR) $(PDFDIR)/$(PROJET).pdf

$(PDFDIR)/$(PROJET).pdf: $(SRCDIR)$(PROJET).tex
	$(MAKEDOC)
	$(PURGE)

.PHONY: spell
spell: dic $(DIC)
	$(PURGE)

$(DIC): dic/%.dic: $(SRCDIR)%.tex
	aspell -d francais -p ./$@ -t -c $<
	@touch $@

$(PDFDIR)/livret-%.pdf: $(PDFDIR)/%.pdf
	pdfxup -b -kbb -ow -o $@ $< >/dev/null
$(PDFDIR)/portrait-%.pdf: $(PDFDIR)/livret-%.pdf
	pdfjam --angle 90 -q -o $@ $<
$(PDFDIR)/extrait-%.pdf: $(PDFDIR)/%.pdf
	pdfjam -q -o $@ $< $(P)

define dependances-courantes
	deps=`sed \
	-e 's/^.*: //' \
	-e '/^[^ ]* $$/d' \
	-e '/^section-.*/d' $1`
endef
define dependances-uniques
	sed 's/ /\n/g' $1 | sed -n '1p' >$1.tmp; \
	sed 's/ /\n/g' $1 | sed -e '1d' -e '/^$$/d' | \
	sort | uniq >>$1.tmp; \
	cat $1.tmp | tr '\n' ' ' >$1; \
	echo >>$1; \
	$(RM) $1.tmp
endef
define dependances-vers-les-autres
	$(call dependances-courantes,$1); \
	if [ -n "$$deps" ]; then \
		cible=`echo $1 | sed \
		-e 's@dep/\(.*\)\.dep@\1.tex@'`; \
		for f in `ls dep/*/*.dep`; do \
			if [ $$f != $1 ]; then \
				sed -i "s@ $$cible @ $$deps@" $$f; \
				$(call dependances-uniques,$$f); \
			fi; \
		done; \
	fi
endef
define dependances-depuis-les-autres
	for f in `ls dep/*/*.dep`; do \
		if [ $$f != $1 ]; then \
			$(call dependances-courantes,$$f); \
			if [ -n "$$deps" ]; then \
				cible=`echo $$f | sed \
				-e 's@dep/\(.*\)\.dep@\1.tex@'`; \
				sed -i "s@ $$cible @ $$deps@" $1; \
			fi; \
		fi; \
	done; \
	$(call dependances-uniques,$1)
endef
define dependances
	name=`echo $1 | sed 's@dep/\(.*\)\.dep@\1@'`; \
	echo -n  "$(PDFDIR)/`basename $1 .dep`.pdf: $$name.tex " \
	>dep/$$name.dep; \
	sed \
	-e 's/\\%/PourCent/g' \
	-e 's/%.*//' \
	-e 's/PourCent/\\%/g' $$name.tex | \
	grep -e '\\input' -e '\\includegraphics' -e '\\verbatiminput' | \
	tr '\n' ' ' | \
	sed 's/\\input[{ ]*\([^} ]*\)/\n\1.tex\n/g' | \
	sed 's/\\includegraphics[{ ]*\([^} ]*\)/\n\1.pdf\n/g' | \
	sed 's/\\verbatiminput[{ ]*\([^} ]*\)/\n\1.sh\n/g' | \
	grep -e '.tex' -e '.pdf' -e '.sh' | \
	sed \
	-e 's/\.tex\.tex/.tex/g' \
	-e 's/\.pdf\.pdf/.pdf/g' \
	-e 's/\.sh\.sh/.sh/g' | \
	tr '\n' ' ' >>dep/$$name.dep; \
	echo >>dep/$$name.dep; \
	$(call dependances-vers-les-autres,dep/$$name.dep); \
	$(call dependances-depuis-les-autres,dep/$$name.dep)
endef

.PHONY: dep
dep:
	@for file in $(DEP); do \
		if [ -f $$file ]; then \
			mv $$file $$file.bak; \
		fi; \
	done
	@for file in $(DEP); do \
		$(call dependances,$$file); \
		echo -n "Dependances de "; cat $$file; \
	done
	@for file in `find . -name "*.dep" -print`; do \
		if diff $$file.bak $$file >/dev/null 2>&1; then \
			mv $$file.bak $$file; \
		fi; \
	done
-include $(wildcard dep/*/*.dep)

dep: dep/$(SRCDIR) dep/$(SECDIR)

$(OBJ) $(PDFDIR)/$(PROJET).pdf: $(MAKEFILE_LIST)
