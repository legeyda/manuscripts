name:=manuscripts
version=$(shell cat VERSION)

# get version
version2:=$(shell cat VERSION)
ifeq (${version2},) 
version2:=0.1.0
endif



SHELL=/bin/sh

DESTDIR?=
prefix?=/usr/local
exec_prefix?=${prefix}
bindir?=${exec_prefix}/bin
datarootdir?=${prefix}/share
datadir?=${datarootdir}
owndatadir?=${datadir}/${name}

source_dir=src
target_dir=target

uninstall_script=${DESTDIR}${owndatadir}/uninstall

.PHONY: all
all: script-all share-all

.PHONY: check
check: script-check

.PHONY: clean
clean: script-clean share-clean
	rm -rf ${target_dir}

${target_dir}: 
	mkdir -p $@


.PHONY: install
install: script-install share-install install-uninstaller
	mkdir -p $(shell dirname '${uninstall_script}')
	echo '#!/usr/bin/env bash' > '${uninstall_script}'
	$(MAKE) --silent --dry-run uninstall >> '${uninstall_script}'
	chmod ugo+x '${uninstall_script}'

.PHONY: uninstall
uninstall: script-uninstall share-uninstall

.PHONY: install-uninstaller
install-uninstaller:
	echo '#!/usr/bin/env bash' > '${DESTDIR}${owndatadir}/uninstall'
	$(MAKE) --silent --dry-run uninstall >> '${DESTDIR}${owndatadir}/uninstall'
	chmod ugo+x '${uninstall_script}'





######## include ########

include_main_include_dir=${source_dir}/main/include

# fun: $(call process_includes,<input file>,<outout file>)
# txt: reads input file, replaces all placeholders and saves to output file
define process_includes
	@data=$$(sed -e 's|{{prefix}}|${prefix}|g; s|{{name}}|${name}|g; s|{{version}}|${version}|g; s|{{owndatadir}}|${owndatadir}|g;' $(1)); \
	test -d ${include_main_include_dir} && find ${include_main_include_dir} -type f | while read file; do \
		what="{{include:$$file}}"; \
		with=$$(cat "src/main/include/$$file"); \
		data="$${data//$$what/$$with}"; \
	done; \
	echo "$$data" > $(2)
endef




######## script-main ########

script_main_source_dir=${source_dir}/main/script
script_main_source_names=$(shell find ${script_main_source_dir} -type f -printf '%P ')
script_main_target_dir=${target_dir}/main/script
script_main_target_files=$(addprefix ${script_main_target_dir}/,${script_main_source_names})

${script_main_target_dir}/%: ${script_main_source_dir}/%
	mkdir -p $(dir $@)
	$(call process_includes,$<,$@)
	chmod ugo+x $@

.PHONY: script-all
script-all: ${script_main_target_files}

.PHONY: script-install
script-install: script-all
	mkdir -p ${DESTDIR}${bindir}
	install --compare ${script_main_target_files} ${DESTDIR}${bindir}

.PHONY: script-uninstall
script-uninstall:
	rm -f $(addprefix ${DESTDIR}${bindir}/,$(notdir ${script_main_source_names}))

.PHONY: script-clean
script-clean:
	rm -rf ${script_main_target_dir}




######## script-test ########

script_test_source_dir=${source_dir}/test/script
script_test_source_names=$(shell find ${script_test_source_dir} -type f -printf '%P ')
script_test_target_dir=${target_dir}/test/script

.PHONY: script-check-install
script-check-install:
	$(MAKE) DESTDIR=$(abspath ${target_dir}/script-check-prefix) script-install share-install

${script_test_target_dir}/%: ${script_test_source_dir}/%
	mkdir -p $(dir $@)
	$(call process_includes,$<,$@)
	chmod ugo+x $@

.PHONY: script-check-%
script-check-%: ${script_test_target_dir}/% script-check-install 
	PATH=${target_dir}/script-check-prefix/${bindir}:$$PATH bash $<

.PHONY: script-check
script-check: $(addprefix script-check-,${script_test_source_names})

.PHONY: script-check
script-check-clean:
	rm -rf ${target_dir}/script-check-prefix




######## share ########

share_main_source_dir=${source_dir}/main/share
share_main_source_names=$(shell find ${share_main_source_dir} -type f -printf '%P ')
share_main_target_dir=${target_dir}/main/share

${share_main_target_dir}/%: ${share_main_source_dir}/%
	mkdir -p $(dir $@)
	$(call process_includes,$<,$@)

.PHONY: share-all
share-all: $(addprefix ${share_main_target_dir}/,${share_main_source_names})

.PHONY: share-install
share-install: share-all
	mkdir -p '${DESTDIR}${owndatadir}'
	cp -rf ${share_main_target_dir}/. '${DESTDIR}${owndatadir}'

.PHONY: share-uninstall
share-uninstall:
	rm -rf ${DESTDIR}${owndatadir}

.PHONY: share-clean
share-clean:
	rm -rf ${share_main_target_dir}
