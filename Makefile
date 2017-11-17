
SRC=src
TARGET=target
BIN=${TARGET}/bin

.PHONY: all
all: foreach sub-foreach intellij-idea-trial-reset.cmd blade-runner daemonize.cmd daemonize.vbs

.PHONY: clean
clean:
	rm -rf ${TARGET}

${TARGET}:
	mkdir -p $@

${BIN}: target
	mkdir -p $@

.PHONY: idea
idea: intellij-idea-trial-reset.cmd


# usage: make_target script-name src-extension target-extension
# e.g. make_target script .bash .sh
define make_target=
.PHONY:           ${1}${3}
${1}${3}:         $${BIN}/${1}${3}
$${BIN}/${1}${3}: $${SRC}/${1}${2} $${BIN}
	cp -T $$< $$@
endef

$(eval $(call make_target,foreach,.sh,))
$(eval $(call make_target,sub-foreach,.sh,))
$(eval $(call make_target,intellij-idea-trial-reset,.cmd,.cmd))
$(eval $(call make_target,blade-runner,.sh,))
$(eval $(call make_target,daemonize,.cmd,.cmd))
$(eval $(call make_target,daemonize,.vbs,.vbs))



