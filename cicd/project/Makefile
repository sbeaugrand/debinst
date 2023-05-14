gitlabci = gitlabci-local -c gitlab-ci.yml -H

.SUFFIXES:

.PHONY: all
all:

.PHONY: build tests
build tests:
	@$(gitlabci) $@
