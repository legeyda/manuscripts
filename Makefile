name=manuscripts
version=$(shell cat VERSION)


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
all: all-scripts all-resources

.PHONY: clean
clean:
	rm -rf ${target_dir}

${target_dir}: 
	mkdir -p $@


.PHONY: install
install: install-scripts install-resources
	mkdir -p $(shell dirname '${uninstall_script}')
	echo '#!/usr/bin/env bash' > '${uninstall_script}'
	$(MAKE) --silent --dry-run uninstall >> '${uninstall_script}'
	chmod ugo+x '${uninstall_script}'

.PHONY: uninstall
uninstall: uninstall-scripts uninstall-resources
	rm -rf '${DESTDIR}${prefix}/share/isimple-scripts'




######## scripts ########

script_source_dir=${source_dir}/main/script
script_source_names=$(shell ls -1 ${script_source_dir})
script_sources=$(addprefix ${script_source_dir}/, ${script_source_names})

script_target_dir=${target_dir}/main/script
script_targets=$(addprefix ${script_target_dir}/, ${script_source_names})

${script_target_dir}: target
	mkdir -p $@

${script_target_dir}/%: ${script_source_dir}/% ${script_target_dir}
	cat $< | sed -e 's|{{prefix}}|${prefix}|g; s|{{version}}|${version}|g; s|{{owndatadir}}|${owndatadir}|g;' | bash src/make/script/process-includes > $@

.PHONY: all-scripts
all-scripts: ${script_targets}

.PHONY: install-scripts
install-scripts: ${script_targets}
	mkdir -p ${DESTDIR}${bindir}
	install --compare $^ ${DESTDIR}${bindir}

.PHONY: uninstall-scripts
uninstall-scripts:
	rm -f $(addprefix ${DESTDIR}${bindir}/,${script_source_names})


######## resources ########

test:
	echo '{{version}}' | bash src/make/script/process-includes

resource_source_dir=${source_dir}/main/resource
resource_source_names=$(shell find ${resource_source_dir} -type f | sed -e 's|^${resource_source_dir}/||')
resource_sources=$(addprefix ${resource_source_dir}/, ${resource_source_names})

resource_target_dir=${target_dir}/main/resource
resource_targets=$(addprefix ${resource_target_dir}/, ${resource_source_names})

${resource_target_dir}: target
	mkdir -p $@

.PHONY: all-resources
all-resources: ${resource_target_dir}
	find ${resource_source_dir} -type f | sed -e 's|^${resource_source_dir}/||' | while read FILE; do \
		mkdir -p $$(dirname ${resource_target_dir}/$$FILE); \
		if [[ ${resource_source_dir}/$$FILE -nt ${resource_target_dir}/$$FILE ]]; then \
			echo "processing ${resource_source_dir}/$$FILE to ${resource_target_dir}/$$FILE"; \
			cat ${resource_source_dir}/$$FILE \
					| sed -e 's|{{prefix}}|${prefix}|g; s|{{version}}|${version}|g; s|{{owndatadir}}|${owndatadir}|g;' \
					| bash src/make/script/process-includes \
					> ${resource_target_dir}/$$FILE; \
		fi; \
	done;

.PHONY: install-resources
install-resources: all-resources
	mkdir -p '${DESTDIR}${owndatadir}'
	cp -rf ${resource_target_dir}/. '${DESTDIR}${owndatadir}'

.PHONY: uninstall-resources
uninstall-resources:
	rm -rf ${DESTDIR}${owndatadir}
