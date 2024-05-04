NAME = ubuntu2404
BOX = generic-$(NAME)-libvirt-x64-4.3.14.box
IP = $(shell ip route get 1.2.3.4 | head -n1 | cut -d' ' -f7)

.PHONY: all
all:
	@echo "Usage: terminal1> make http"
	@echo "       terminal2> make build"
	@echo "       terminal2> make ls"
	@echo "       terminal2> make cp"
	@echo "       terminal2> make add"
	@echo "       terminal2> make clean"
	@echo "       terminal2> make mrproper"

.PHONY: http
http:
	@python3 -m http.server

.PHONY: build
build:
	docker build -t robox --build-arg name=$(NAME) --build-arg ip=$(IP) .

.PHONY: ls
ls:
	docker run robox ls -l robox/output

.PHONY: cp
cp:
	docker run -v $(PWD):/pwd robox cp robox/output/$(BOX) /pwd/

.PHONY: add
add:
	vagrant box add generic-VAGRANTSLASH-$(NAME) $(BOX)

.PHONY: clean
clean:
	docker container prune
	docker rmi robox

.PHONY: mrproper
mrproper:
	docker rmi fedora:latest
	sudo $(RM) $(BOX)
