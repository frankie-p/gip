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
	@echo "GIP_TMP=/tmp/gip" >> "$(CONFIG_PATH)"
	@echo "" >> "$(CONFIG_PATH)"
	@echo "# url of the git project" >> "$(CONFIG_PATH)"
	@echo "GIP_REMOTE=<put git url here>" >> "$(CONFIG_PATH)"
	@echo "" >> "$(CONFIG_PATH)"
	@echo "# path to key for securing files" >> "$(CONFIG_PATH)"
	@echo "# generate key: openssl rand 2048 > gip.key" >> "$(CONFIG_PATH)"
	@echo "# encrypt/decryprt: openssl enc -aes-256-cbc -md sha512 -in <path> -k gip.key -out <path>"$(CONFIG_PATH)"
	@echo "#GIP_KEY=~/.ssh/gip/gip.key" >> "$(CONFIG_PATH)"
	@echo "" >> "$(CONFIG_PATH)"
	@echo "# use gip add to add files" >> "$(CONFIG_PATH)"
	@echo "# use gip secure to secure files" >> "$(CONFIG_PATH)"

	@echo "config file created, please edit $(CONFIG_PATH)"
endif

install:
ifneq ("$(shell id -u)", "0")
	@echo "You are not root, run this target as root please"
else
	@cp src/gip-secure /usr/local/bin/gip-secure
	@cp src/gip /usr/local/bin/gip
endif

uninstall:
ifneq ("$(shell id -u)", "0")
	@echo "You are not root, run this target as root please"
else
	@rm -rf "$(CONFIG_DIR)"
	@rm -f "/usr/local/bin/gip"
	@rm -f "/usr/local/bin/gip-secure"
endif
