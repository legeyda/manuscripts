name=manuscript
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

uninstall_script='${DESTDIR}${owndatadir}/uninstall'

.PHONY: all
all: all-script
	echo ${VERSION}

.PHONY: clean
clean:
	rm -rf ${target_dir}

${target_dir}: 
	mkdir -p $@


.PHONY: install
install: install-scripts
	mkdir -p $(dir '${uninstall_script}')
	echo '#!/usr/bin/env bash' > '${uninstall_script}'
	$(MAKE) --silent --dry-run uninstall >> '${uninstall_script}'
	chmod ugo+x '${uninstall_script}'

.PHONY: uninstall
uninstall: uninstall-scripts
	rm -rf '${DESTDIR}${prefix}/share/isimple-scripts'




######## scripts ########

script_source_dir=${source_dir}/main/script
script_source_names=$(shell ls -1 ${script_source_dir})
script_sources=$(addprefix ${script_source_dir}/, ${script_source_names})

script_target_dir=${target_dir}/script
script_targets=$(addprefix ${script_target_dir}/, ${script_source_names})

${script_target_dir}: target
	mkdir -p $@

${script_target_dir}/%: ${script_source_dir}/% ${script_target_dir}
	cat $< | sed -e 's|{{prefix}}|${prefix}|g; s|{{version}}|${version}|g' > $@

.PHONY: all-script
all-scripts: ${script_targets}

.PHONY: install-script
install-scripts: ${script_targets}
	mkdir -p ${DESTDIR}${bindir}
	install --compare $^ ${DESTDIR}${bindir}

.PHONY: uninstall-script
uninstall-scripts:
	rm -f $(addprefix ${DESTDIR}${bindir}/,${script_source_names})

