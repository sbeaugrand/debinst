# ---------------------------------------------------------------------------- #
## \file wiringPi.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += arm/wiringPi
OBJECTS += ${PROROOT}/arm/wiringPi/wiringPi.a
CFLAGS += -I$(PROROOT)/arm/wiringPi

$(PROROOT)/arm/wiringPi/wiringPi.a:
	@cd $(PROROOT)/arm/wiringPi && make --no-print-directory
