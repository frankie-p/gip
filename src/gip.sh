#!/bin/bash

# gip - git based backup system

VERSION=1.0.1
eval CONFIG_PATH="~/.config/gip/gip"

source_config() {
    if [[ ! -f "$CONFIG_PATH" ]] ; then
            echo "config file not found, call --def-config to create default configuration"
            exit
    fi

    source "$CONFIG_PATH"
}

ensure_tmp() {
    if [[ ! -d "$TMP_DIR/.git" ]] ; then
        mkdir -p "$TMP_DIR"

        if [[ -z "$option_verbose" ]] ; then
            git clone $GIT_URL "$TMP_DIR" > /dev/null
        else
            git clone $GIT_URL "$TMP_DIR"
        fi
    fi
}

command_list() {
    for file in "${FILES[@]}" ; do
        echo "$file"
    done
}

command_check() {
    for file in "${FILES[@]}" ; do
        if [[ ! -f "$file" ]] ; then
            echo "$file not found"
            exit
        fi
    done
}

command_update() {
    check_files

    for file in "${FILES[@]}" ; do
        if [[ ! -z "$option_verbose" ]] ; then
            echo  "$file => $TMP_DIR/${file#/}"
        fi

        mkdir -p "$(dirname "$TMP_DIR/${file#/}")"
        cp "$file" "$TMP_DIR/${file#/}"
    done
}

command_commit() {
    if [[ -z "$option_verbose" ]] ; then
        pushd "$TMP_DIR" > /dev/null
        git add . > /dev/null
        git commit -am "gip commit" > /dev/null
        popd > /dev/null
    else
        pushd "$TMP_DIR"
        git add .
        git commit -am "gip commit"
        popd
    fi
}

command_push() {
    if [[ -z "$option_verbose" ]] ; then
        pushd "$TMP_DIR" > /dev/null
        git push > /dev/null
        popd > /dev/null
    else
        pushd "$TMP_DIR"
        git push
        popd
    fi
}

command_status() {
    if [[ -z "$option_verbose" ]] ; then
        pushd "$TMP_DIR" > /dev/null
        git status
        popd > /dev/null
    else
        pushd "$TMP_DIR"
        git status
        popd
    fi
}

# obsolete and will be moved to Makefile install target
def_config() {
    if [[ -f "$CONFIG_PATH" ]] ; then
        echo "config file exists"
        exit
    fi

    mkdir -p "$(dirname "$CONFIG_PATH")"

    echo "# gip - git based backup system" >> "$CONFIG_PATH"
    echo "" >> "$CONFIG_PATH"
    echo "# tmp directory which is used to checkout the git project" >> "$CONFIG_PATH"
    echo "TMP_DIR=/tmp/gip" >> "$CONFIG_PATH"
    echo "" >> "$CONFIG_PATH"
    echo "# url of the git project" >> "$CONFIG_PATH"
    echo "GIT_URL=<put git url here>" >> "$CONFIG_PATH"
    echo "" >> "$CONFIG_PATH"
    echo "# list of files to be backuped" >> "$CONFIG_PATH"
    echo "FILES=(\"/path/file/1\" \"/path/file/2\")" >> "$CONFIG_PATH"

    echo "config file created, please edit $CONFIG_PATH"
}

usage() {
    echo "Usage: gip [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo -e "\tlist            List configured files"
    echo -e "\tstatus          Show status"
    echo -e "\tcheck           Check if configured files exists"
    echo -e "\tupdate          Check and update files (copies configured files to the tmp dir)"
    echo -e "\tcommit          Create local commit"
    echo -e "\tpush            Push commits to git"
    echo -e "\tfull            Same as 'gip update && gip commit && gip push'"
    echo ""
    echo "Options:"
    echo -e "\t-v|--verbose    Verbose outputs"
    echo -e "\t-h|--help       Print help"
    echo -e "\t-V|--version    Print version"
}

# pre parse arguments

args=()

for arg in "$@" ; do
    if [[ $arg == -* && $arg != --* ]] ; then
        for (( i=1; i<${#arg}; i++ )); do
            args+=("-${arg:$i:1}")
        done
    else
        args+=($arg)
    fi
done

#end of pre parse arguments

counter=0

for i in "${args[@]}" ; do
    case $i in
        list)
            do_list=true
            ((counter++))
            ;;
        status)
            do_status=true
            ((counter++))
            ;;
        check)
            do_check=true
            ((counter++))
            ;;
        update)
            do_update=true
            ((counter++))
            ;;
        commit)
            do_commit=true
            ((counter++))
            ;;
        push)
            do_push=true
            ((counter++))
            ;;
        full)
            do_update=true
            do_commit=true
            do_push=true
            ((counter++))
            ;;
        --verbose|-v)
            option_verbose=true
            ;;
        --version|-V)
            echo "$VERSION"
            exit
            ;;
        --help|-h)
            usage
            exit
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

[[ "$counter" -eq "0" ]] && usage && exit 1
[[ "$counter" -ge "2" ]] && echo "multiple commands not supported" && exit 1

source_config
ensure_tmp

if [[ ! -z "$do_list" ]] ; then
    command_list
fi

if [[ ! -z "$do_status" ]] ; then
    command_status
fi

if [[ ! -z "$do_check" ]] ; then
    command_check
fi

if [[ ! -z "$do_update" ]] ; then
    command_update
fi

if [[ ! -z "$do_commit" ]] ; then
    command_commit
fi

if [[ ! -z "$do_push" ]] ; then
    command_push
fi
