#!/bin/bash

# gib - git based backup system

VERSION=1.0.0
eval CONFIG_PATH="~/.config/gib"

source_config() {
	if [[ ! -f "$CONFIG_PATH" ]] ; then
        	echo "config file not found, call --def-config to create default configuration"
        	exit
	fi

	source "$CONFIG_PATH"
}

ensure() {
	if [[ ! -d "$TMP_DIR/.git" ]] ; then
		mkdir -p "$TMP_DIR"
		git clone $GIT_URL "$TMP_DIR"
	fi
}

copy_tmp() {
	# check files before start copy

	for file in "${FILES[@]}" ; do
                if [[ ! -f "$file" ]] ; then
			echo "file $file not found"
		     	 exit
                fi
	done

	# start copy routine

	for file in "${FILES[@]}" ; do
		echo  "$file => $TMP_DIR/${file#/}"

		mkdir -p "$(dirname "$TMP_DIR/${file#/}")"
		cp "$file" "$TMP_DIR/${file#/}"
	done
}

commit() {
	pusdh "$TMP_DIR"

	# add new files
	git add .

	git commit -am "gib commit"

	popd
}

def_config() {
	if [[ -f "$CONFIG_PATH" ]] ; then
		echo "config file exists"
		exit
	fi

	echo "# gib - git based backup system" >> "$CONFIG_PATH"
	echo "" >> "$CONFIG_PATH"
	echo "# tmp directory which is used to checkout the git project" >> "$CONFIG_PATH"
	echo "TMP_DIR=/tmp/gib" >> "$CONFIG_PATH"
	echo "" >> "$CONFIG_PATH"
	echo "# url of the git project" >> "$CONFIG_PATH"
	echo "GIT_URL=<put git url here>" >> "$CONFIG_PATH"
	echo "" >> "$CONFIG_PATH"
	echo "# list of files to be backuped" >> "$CONFIG_PATH"
	echo "FILES=(\"/path/file/1\" \"/path/file/2\")" >> "$CONFIG_PATH"

	echo "config file created, please edit $CONFIG_PATH"
}

source_config
ensure
copy_tmp


