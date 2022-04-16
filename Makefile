include makefiles/Makefile.base
include makefiles/Makefile.include
include makefiles/Makefile.script
include makefiles/Makefile.share
include makefiles/Makefile.uninstaller

######## standard targets ########

target_dir?=target

.PHONY: all
all: script-all share-all

.PHONY: check
check: script-check

.PHONY: clean
clean: script-clean script-check-clean share-clean
	rm -rf ${target_dir}

.PHONY: install
install: script-install share-install uninstaller-install

.PHONY: uninstall
uninstall: script-uninstall share-uninstall uninstaller-uninstall