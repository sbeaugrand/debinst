# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = mailsender
PROROOT = ..
MyName ?= beaugrand
D ?= 15
L ?= mail-pr-.list
M ?= message-pr-.txt
S ?= mail-pr-.supp

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo "Extract email addresses :"
	@echo " ./extract.py ~/Mail/recus/"
	@echo " ./extract.py ~/Mail/"
	@echo " ./extract.py ~/Mail/ >>$(L)"
	@echo
	@echo "Cleanup :"
	@echo " make uniq     >$(L).out"
	@echo "            cat $(L).out >>$(L)"
	@echo " make check    >$(S).out"
	@echo "            cat $(S).out >>$(S)"
	@echo " make purge"
	@echo " make nmap     >$(S).out"
	@echo "            cat $(S).out >>$(S)"
	@echo " make purge"
	@echo
	@echo "Send :"
	@echo " ./split.sh mail-pr-.list"
	@echo " \\mutt  # compose a mail draft"
	@echo " vi \`ls -1rt ~/Mail/brouillons/new/* | tail -1\`  # :r x-pr-00.list"
	@echo " \\mutt  # send the mail draft"
	@echo
	@echo "Send one by one (less usefull):"
	@echo " nohup ./send.sh 'Tr: ' $(M) $(L) $(D) &"
	@echo
	@echo "Undelivered messages :"
	@echo " grep -h '^To: ' ~/Mail/recus/new/* | grep -v $(MyName) | uniq | sed 's/^To: //' >$(S).out"
	@echo " grep -h '^Original-Recipient: ' ~/Mail/recus/new/* | sed 's/.*;//' >>$(S).out"
	@echo " cat $(S).out >>$(S)"
	@echo " make purge"
	@echo " grep -c '^To: ' * | grep ':1$$'"
	@echo
	@echo "Archive :"
	@echo " ./archive.sh"
	@echo " make mrproper"
	@echo " make tar"
	@echo
	@echo "Extract files :"
	@echo " ./archive.sh x"
	@echo

.PHONY: uniq
uniq:
	@cat $(L) | ./uniq.py

.PHONY: check
check:
	grep -v '\.\(fr\|com\|org\|net\|edu\|be\|de\|it\|uk\|ch\|eu\|es\|info\|au\|ca\|is\|dk\|nu\|in\|br\|st\|il\)$$' $(L); true

.PHONY: nmap
nmap:
	@cat $(L) | sed 's/.*@//' | sort -u |\
	 xargs -I {} nmap -n -sn {} 2>&1 | grep Failed |\
	 sed -e 's/[^"]*"//' -e 's/".*//' | xargs -I {} grep @{} $(L)

.PHONY: purge
purge:
	@./delete.sh $(L) $(S)

.PHONY: clean
clean:
	@$(RM) *.out *~

.PHONY: mrproper
mrproper: clean
	@ls -1rt *-pr-* | tail -1 | grep -q mail-pr-.7z
	@$(RM) -v *-pr- *-pr-*.list *-pr-*.supp *-pr-*.txt

include $(PROROOT)/makefiles/tar.mk
