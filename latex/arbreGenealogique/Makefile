# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# convert-im6 cache resources exhausted :
#   sudo vi /etc/ImageMagick-6/policy.xml +57  # name="area" value="256MiB"
# Photocopy filter :
#   http://www.imagemagick.org/Usage/photos/#color-in
#   make F=photocopy
# Blur filter :
#   make F=blur
# Suppression file :
#   make check-notes | sort -k2 >gramps-pr-checkNotes.supp
# ---------------------------------------------------------------------------- #
PROJECT = arbreGenealogique
PROROOT = ..
PHOTOS = /data/arbreGenealogiquePhotos
PHOTO_W = 555
PHOTO_H = 697
PHOTO_WM1 = $(shell echo "$(PHOTO_W) - 1" | bc)
PHOTO_HM1 = $(shell echo "$(PHOTO_H) - 1" | bc)
PHOTO_3W = 1771# 15cm
PHOTO_3H = 2480# 21cm
ifeq ($(F),photocopy)
 EXEMPLE  = -colorspace gray \( +clone -blur 0x1 \) +swap\
            -compose divide -composite -linear-stretch 2%x0%
 EXEMPLE3 = -colorspace gray \( +clone -blur 0x2 \) +swap\
            -compose divide -composite -linear-stretch 5%x0%
else ifeq ($(F),blur)
 EXEMPLE = -blur 0x30
 EXEMPLE3 = -resize $(PHOTO_W)x$(PHOTO_H)\! -blur 0x30\
            -resize $(PHOTO_3W)x$(PHOTO_3H)\!
else ifneq ($(F),)
 $(error Unknown filter $(F))
endif

.SUFFIXES:

.PHONY: all
all: $(PROJECT).pdf

build:
	@mkdir $@

$(PROJECT).pdf: $(PROJECT).tex\
 export-pr-H2-9.tex\
 export-pr-F2-9.tex\
 enfants-pr-H1.tex\
 enfants-pr-F1.tex\
 build\
 build/I0000.png\
 build/I0001.png\
 build/I0002.png\
 build/I0003.png\
 build/I0004.png\
 build/I0005.png\
 build/I0006.png\
 build/I0007.png\
 build/I0008.png\
 build/I0009.png\
 build/I0010.png\
 build/I0011.png\
 build/I0012.png\
 build/I0013.png\
 build/I0015.png\
 build/I0016.png\
 build/I0017.png\
 build/I0018.png\
 build/I0019.png\
 build/I0032.png\
 build/I0033.png\
 build/I0034.png\
 build/I0035.png\
 build/I0054.png\
 build/I0105.png\
 build/I0393.png\
 build/I1570.png\
 build/I1571.png\

	@pdflatex --halt-on-error $<
	@$(RM) $(PROJECT).aux $(PROJECT).log

.PHONY: 10x15
10x15:\
 build/I0010I0013.png\
 build/I0016I1571.png\
 build/I0018I0105.png\
 build/I0006I0393.png\
 build/I0032I0035.png\
 build/I0000I0009.png\

export-pr-H%.tex: export-pr-%.csv gramps2tex.php randomColor.php
	@php gramps2tex.php $< 1 8 576 50 >$@

export-pr-F%.tex: export-pr-%.csv gramps2tex.php randomColor.php
	@php gramps2tex.php $< 2 8 576 50 >$@

build/ellipse.png:
	@convert -size $(PHOTO_W)x$(PHOTO_H) xc:white -fill black\
	 -draw "ellipse "\
	"$(shell echo "$(PHOTO_W) / 2 + 1" | bc),"\
	"$(shell echo "$(PHOTO_H) / 2 + 1" | bc) "\
	"$(shell echo "$(PHOTO_W) / 2" | bc),"\
	"$(shell echo "$(PHOTO_H) / 2" | bc) 0,360" $@

build/ellipse3.png:
	@convert -size $(PHOTO_3W)x$(PHOTO_3H) xc:white -fill black\
	 -draw "ellipse "\
	"$(shell echo "$(PHOTO_3W) / 2 + 1" | bc),"\
	"$(shell echo "$(PHOTO_3H) / 2 + 1" | bc) "\
	"$(shell echo "$(PHOTO_3W) / 2" | bc),"\
	"$(shell echo "$(PHOTO_3H) / 2" | bc) 0,360" $@

define photo
	@echo $@
	@convert -units PixelsPerInch $< $3 -crop $(PHOTO_W)x$(PHOTO_H)+$1+$2 \
	-normalize $(EXEMPLE) -density 300 tmp.png
	@convert tmp.png build/ellipse.png -compose Screen -composite +repage \
	-font Liberation-Sans -pointsize 18 -draw "text \
	$(shell echo "$(PHOTO_W) - 45" | bc),\
	$(shell echo "$(PHOTO_H) - 5" | bc) '$4'" $@
	@rm tmp.png
endef

define photo3
	@echo $@
	@convert -units PixelsPerInch $< $3 -crop $(PHOTO_3W)x$(PHOTO_3H)+$1+$2 \
	-normalize $(EXEMPLE3) -density 300 tmp.png
	@convert tmp.png build/ellipse3.png -compose Screen -composite +repage \
	-font Liberation-Sans -pointsize 18 -draw "text \
	$(shell echo "$(PHOTO_3W) - 45" | bc),\
	$(shell echo "$(PHOTO_3H) - 5" | bc) '$4'" $@
	@rm tmp.png
endef

build/I0000.png: $(PHOTOS)/sebastien.png build/ellipse.png
	$(call photo,40,60,-resize 50%,2016)

build/I0001.png: $(PHOTOS)/emma.png build/ellipse3.png
	$(call photo3,50,200,-resize 25%,2019)

build/I0002.png: $(PHOTOS)/eric.png build/ellipse3.png
	$(call photo3,125,100,-resize 25%,2019)

build/I0003.png: $(PHOTOS)/erwann.png build/ellipse3.png
	$(call photo3,75,100,-resize 25%,2019)

build/I0004.png: $(PHOTOS)/eline.png build/ellipse3.png
	$(call photo3,600,2900,-resize 50%,2019)

build/I0005.png: $(PHOTOS)/audrey.jpg build/ellipse.png
	$(call photo,100,50,-resize 200%,2016)

build/I0006.png: $(PHOTOS)/bernard.png build/ellipse.png
	$(call photo,80,60,-resize 95%,,$@)

build/I0007.png: $(PHOTOS)/danielle.jpg build/ellipse.png
	$(call photo,570,350,-resize 175%,2004)

build/I0008.png: $(PHOTOS)/patrice.png build/ellipse.png
	$(call photo,140,120,-resize 95%,)

build/I0009.png: $(PHOTOS)/josiane.png build/ellipse.png
	$(call photo,220,220,-resize 80%,)

build/I0010.png: $(PHOTOS)/leon.png build/ellipse.png
	$(call photo,40,60,-resize 70%,1946)

build/I0011.png: $(PHOTOS)/jeanine.png build/ellipse.png
	$(call photo,100,150,-resize 70%,1946)

build/I0012.png: $(PHOTOS)/rene.png build/ellipse.png
	$(call photo,70,90,-resize 80%,1954)

build/I0013.png: $(PHOTOS)/denise.png build/ellipse.png
	$(call photo,120,170,-resize 90%,1953)

build/I0015.png: $(PHOTOS)/jeanne.png build/ellipse.png
	$(call photo,90,70,-resize 45%,)

build/I0016.png: $(PHOTOS)/henri-eugenie.png build/ellipse.png
	$(call photo,520,420,-resize 75%,1914)

build/I0017.png: $(PHOTOS)/henri-eugenie.png build/ellipse.png
	$(call photo,1250,600,-resize 75%,1914)

build/I0018.png: $(PHOTOS)/germain-felicite.png build/ellipse.png
	$(call photo,130,150,-resize 75%,1909)

build/I0019.png: $(PHOTOS)/germain-felicite.png build/ellipse.png
	$(call photo,1070,150,-resize 75%,1909)

build/I0032.png: $(PHOTOS)/pierre.png build/ellipse.png
	$(call photo,110,40,-resize 80%,)

build/I0033.png: $(PHOTOS)/emilienne.png build/ellipse.png
	$(call photo,40,30,-resize 80%,)

build/I0034.png: $(PHOTOS)/georges-berthe.png build/ellipse.png
	$(call photo,620,80,-resize 70%,)

build/I0035.png: $(PHOTOS)/georges-berthe.png build/ellipse.png
	$(call photo,140,200,-resize 70%,)

build/I0054.png: $(PHOTOS)/louis-ernestine.png build/ellipse.png
	$(call photo,1120,430,-resize 70%,)

build/I0105.png: $(PHOTOS)/louis-ernestine.png build/ellipse.png
	$(call photo,1880,840,-resize 70%,)

build/I0393.png: $(PHOTOS)/marie.png build/ellipse.png
	$(call photo,200,140,-resize 60%,)

build/I1570.png: $(PHOTOS)/andre-marie.png build/ellipse.png
	$(call photo,1100,700,-resize 75%,1923)

build/I1571.png: $(PHOTOS)/andre-marie.png build/ellipse.png
	$(call photo,1700,750,-resize 75%,1923)

define photoExtent
	convert build/$1 -fill none -stroke black\
	 -draw "rectangle 0,0,$(PHOTO_WM1),$(PHOTO_HM1)"\
	 -gravity Center -extent 590x885 build/tmp$1
endef

define photoExtent2
	@echo $@
	@for file in $(notdir $^); do \
		$(call photoExtent,$$file); \
	done; \
	convert $(addprefix build/tmp,$(notdir $^)) +append\
	 -font Liberation-Sans -pointsize 18\
	 -draw "text 250,850 '$1'" -draw "text 850,850 '$2'" $@; \
	rm $(addprefix build/tmp,$(notdir $^))
endef

build/I0010I0011.png: build/I0010.png build/I0011.png
	$(call photoExtent2,Léon,Jeanine)

build/I0012I0013.png: build/I0012.png build/I0013.png
	$(call photoExtent2,René,Denise)

build/I0010I0013.png: build/I0010I0011.png build/I0012I0013.png
	@echo $@
	@convert $^ -append $@

build/I0016I0017.png: build/I0016.png build/I0017.png
	$(call photoExtent2,Henri Marcel,Eugénie Léontine)

build/I1570I1571.png: build/I1570.png build/I1571.png
	$(call photoExtent2,André René,Marie Geneviève)

build/I0016I1571.png: build/I0016I0017.png build/I1570I1571.png
	@echo $@
	@convert $^ -append $@

build/I0018I0019.png: build/I0018.png build/I0019.png
	$(call photoExtent2,Germain Henri Lucien,Félicité Éléonore)

build/I0054I0105.png: build/I0054.png build/I0105.png
	$(call photoExtent2,Louis Honoré,Ernestine Célina)

build/I0018I0105.png: build/I0018I0019.png build/I0054I0105.png
	@echo $@
	@convert $^ -append $@

build/I0006I0007.png: build/I0006.png build/I0007.png
	$(call photoExtent2,Bernard,Danielle)

build/I0015I0393.png: build/I0015.png build/I0393.png
	$(call photoExtent2,Jeanne Léontine Adrienne,Marie Julia)

build/I0006I0393.png: build/I0006I0007.png build/I0015I0393.png
	@echo $@
	@convert $^ -append $@

build/I0032I0033.png: build/I0032.png build/I0033.png
	$(call photoExtent2,Pierre,Émilienne Louise)

build/I0034I0035.png: build/I0034.png build/I0035.png
	$(call photoExtent2,Georges Edmond,Berthe Adrienne Louise)

build/I0032I0035.png: build/I0032I0033.png build/I0034I0035.png
	@echo $@
	@convert $^ -append $@

build/I0000I0005.png: build/I0000.png build/I0005.png
	$(call photoExtent2,Sébastien,Audrey)

build/I0008I0009.png: build/I0008.png build/I0009.png
	$(call photoExtent2,Patrice,Josiane)

build/I0000I0009.png: build/I0000I0005.png build/I0008I0009.png
	@echo $@
	@convert $^ -append $@

.PHONY: a4
a4: a4.pdf

a4.pdf: $(PROJECT).pdf
	pdfposter -p4x4A4 $< $@

.PHONY: test-rgb
test-rgb: testRGB.pdf

testRGB.pdf: testRGB.tex
	@pdflatex --halt-on-error $<
	@$(RM) testRGB.aux testRGB.log

testRGB.tex: testRGB.php randomColor.php
	@php $< >$@

.PHONY: check-notes
check-notes:
	@./grampsCheckNotes.py\
	 `grep '^\[I0000' export-pr-2-9.csv | cut -d ',' -f 2` 9

.PHONY: check-supp
check-supp:
	@sort -k2 gramps-pr-checkNotes.supp | diff gramps-pr-checkNotes.supp -

.PHONY: todo
todo: GP1.pdf GP2.pdf GP3.pdf GP4.pdf

GP%.pdf: build/GP%.tex
	@pdflatex --halt-on-error $<
	@$(RM) `basename $@ .pdf`.aux `basename $@ .pdf`.log

build/GP%.tex: gramps-pr-checkNotes.supp header.tex
	@cat header.tex >$@
	@grep `basename $@ .tex` $< >>$@
	@printf '\\end{lstlisting}\n' >>$@
	@printf '\\end{document}\n' >>$@

portrait-%.pdf: %.pdf
	@pdf90 -q -o $@ $<

.PHONY: clean-gedcom
clean-gedcom: geneanet-pr-gedcom9.ged

geneanet-pr-gedcom9.ged: export-pr-gedcom9.ged\
 export-pr-2-9.csv grampsGedcomFamc.py
	@cp $< $@
	@./grampsGedcomFamc.py\
	 `grep '^\[I0000' export-pr-2-9.csv | cut -d ',' -f 2` 9 |\
	 xargs -I {} sed -i -e '/0 @{}@ FAM/,/^0/{/^0/!d}' -e '/@{}@/d' $@
	@diff $< $@ | grep -c '< 1 FAMC'
	@diff $< $@ | grep -c '< 0'

.PHONY: check-medias
check-medias:
	@db=`grep '^\[I0000' export-pr-2-9.csv | cut -d ',' -f 2` &&\
	 ./grampsCheckMedias.py $$db /data/$$db.gpkg.media

.PHONY: clean
clean:
	@$(RM) *~ $(PROJECT).aux $(PROJECT).log

include $(PROROOT)/makefiles/tar.mk
