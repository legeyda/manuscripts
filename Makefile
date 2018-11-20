name:=$(shell basename $$(pwd))
version=$(shell cat VERSION)

SHELL=/bin/bash
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
clean: script-clean script-check-clean share-clean
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

include_main_source_dir=${source_dir}/main/include
include_main_source_names=$(shell test -d ${include_main_source_dir} && find ${include_main_source_dir} -type f -printf '%P ')


# fun: $(call process_includes,<input file>,<output file>)
# txt: reads input file, replaces all placeholders and saves to output file
#      handles binary files, but is somewhat slower
define process_includes_on_disk
	set -e; \
	sed -e 's|{{prefix}}|${prefix}|g; s|{{name}}|${name}|g; s|{{version}}|${version}|g; s|{{owndatadir}}|${owndatadir}|g;' '$(1)' > '$(2)'; \
	test -d ${include_main_source_dir} && find ${include_main_source_dir} -type f -printf '%P\n' | while read file; do \
		what="{{include:$$file}}"; \
		with=$$(cat "${include_main_source_dir}/$$file" | sed -e 's|&|\\\\&|g;'); \
		awk -i inplace -v "what=$$what" -v "with=$$with" '{gsub(what, with); print}' '$(2)'; \
	done || true
endef

# fun: 
define process_include_file
	what="{{include:$(1)}}"; \
	with=$$(cat "${include_main_source_dir}/$(1)" | sed -e 's|&|\\\\&|g;' ); \
	data=$$(echo "$$data" | awk -v "what=$$what" -v "with=$$with" '{gsub(what, with); print}');
endef

# fun: $(call process_includes,<input file>,<output file>)
# txt: reads input file, replaces all placeholders and saves to output file
#      seems to be faster, but corrupts binary files
define process_includes_in_memory
	set -e; \
	data=$$(sed -e 's|{{prefix}}|${prefix}|g; s|{{name}}|${name}|g; s|{{version}}|${version}|g; s|{{owndatadir}}|${owndatadir}|g;' $(1)); \
	$(foreach name,${include_main_source_names},$(call process_include_file,${name})) \
	echo "$$data" > '$(2)'
endef

# we do not have binary files now, so use faster option
define process_includes
	${process_includes_in_memory}
endef


######## script-main ########

script_main_source_dir=${source_dir}/main/script
script_main_source_names=$(shell test -d ${script_main_source_dir} && find ${script_main_source_dir} -type f -printf '%P ')
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
script_test_source_names=$(shell test -d ${script_test_source_dir} && find ${script_test_source_dir} -type f -printf '%P ')
script_test_target_dir=${target_dir}/test/script

.PHONY: script-check-fake-install
script-check-fake-install:
	$(MAKE) DESTDIR=$(abspath ${target_dir}/script-check-prefix) script-install share-install

${script_test_target_dir}/%: ${script_test_source_dir}/%
	mkdir -p $(dir $@)
	$(call process_includes,$<,$@)
	chmod ugo+x $@

.PHONY: script-check-%
script-check-%: ${script_test_target_dir}/% script-check-fake-install 
	PATH=${target_dir}/script-check-prefix/${bindir}:$$PATH bash $<

.PHONY: script-check
script-check: $(addprefix script-check-,${script_test_source_names})

.PHONY: script-check
script-check-clean:
	rm -rf ${target_dir}/script-check-prefix




######## share ########

share_main_source_dir=${source_dir}/main/share
share_main_source_names=$(shell test -d ${share_main_source_dir} && find ${share_main_source_dir} -type f -printf '%P ')
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
