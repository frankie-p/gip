CONFIG_PATH=$(HOME)/.config/gip/gip
CONFIG_DIR=$(shell dirname $(CONFIG_PATH))

error:
	@echo "Use sudo make install, sudo make uninstall or make def_config"

def_config:
ifneq ("$(wildcard $(CONFIG_PATH))","")
	@echo "Config file already exists"
else
ifeq ("$(wildcard $(CONFIG_DIR))","")
	@mkdir -p "$(CONFIG_DIR)"
endif
	@echo "# gip - git based backup system" >> "$(CONFIG_PATH)"
	@echo "" >> "$(CONFIG_PATH)"
	@echo "# tmp directory which is used to checkout the git project" >> "$(CONFIG_PATH)"
	@echo "TMP_DIR=/tmp/gip" >> "$(CONFIG_PATH)"
	@echo "" >> "$(CONFIG_PATH)"
	@echo "# url of the git project" >> "$(CONFIG_PATH)"
	@echo "GIT_URL=<put git url here>" >> "$(CONFIG_PATH)"
	@echo "" >> "$(CONFIG_PATH)"
	@echo "# list of files to be backuped" >> "$(CONFIG_PATH)"
	@echo "FILES=(\"/path/file/1\" \"/path/file/2\")" >> "$(CONFIG_PATH)"

	@echo "config file created, please edit $(CONFIG_PATH)"
endif

install:
ifneq ("$(shell id -u)", "0")
	@echo "You are not root, run this target as root please"
else
	@cp src/gip.sh /usr/local/bin/gip
endif

uninstall:
ifneq ("$(shell id -u)", "0")
	@echo "You are not root, run this target as root please"
else
	@rm -f "$(CONFIG_PATH)"
	@rm -f "/usr/local/bin/gip"
endif
