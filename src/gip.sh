#!/bin/bash

# gip - git based backup system

VERSION=1.0.3
eval CONFIG_PATH="~/.config/gip/gip"

source_config() {
    if [[ ! -f "$CONFIG_PATH" ]] ; then
            echo "missing config file"
            exit 1
    fi

    source "$CONFIG_PATH"
}

ensure_tmp() {
    if [[ ! -d "$TMP_DIR/.git" ]] ; then
        mkdir -p "$TMP_DIR"

        if [[ -z "$option_verbose" ]] ; then
            git clone --quiet $GIT_URL "$TMP_DIR" > /dev/null
        else
            git clone $GIT_URL "$TMP_DIR"
        fi
    fi
}

command_edit() {
	"$EDITOR" "$CONFIG_PATH"
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
            has_error=true
        fi
    done

    if [[ ! -z "$has_error" ]] ; then
        exit 1
    fi
}

command_update() {
    command_check

    for file in "${FILES[@]}" ; do
        if [[ ! -z "$option_verbose" ]] ; then
            echo  "$file => $TMP_DIR/${file#/}"
        fi

        mkdir -p "$(dirname "$TMP_DIR/${file#/}")"
        cp "$file" "$TMP_DIR/${file#/}"
    done
}

command_commit() {
    if [[ -z "$option_message" ]] ; then
        option_message="gip commit"
    fi

    if [[ -z "$option_verbose" ]] ; then
        pushd "$TMP_DIR" > /dev/null
        git add . > /dev/null
        git commit -am "$option_message" > /dev/null
        popd > /dev/null
    else
        pushd "$TMP_DIR"
        git add .
        git commit -am "$option_message"
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

usage() {
    echo "Usage: gip [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo -e "\tedit            Use system editor to edit config file"
    echo -e "\tlist            List configured files"
    echo -e "\tstatus          Show status"
    echo -e "\tcheck           Check if configured files exists"
    echo -e "\tupdate          Check and update files (copies configured files to the tmp dir)"
    echo -e "\tcommit          Create local commit"
    echo -e "\tpush            Push commits to git"
    echo -e "\tfull            Same as 'gip update && gip commit && gip push'"
    echo ""
    echo "Options:"
    echo -e "\t-m|--message    Commit message"
    echo -e "\t-v|--verbose    Verbose outputs"
    echo -e "\t-h|--help       Print help"
    echo -e "\t-V|--version    Print version"
}

# pre parse arguments

#args=()

#for arg in "$@" ; do
#    if [[ $arg == -* && $arg != --* ]] ; then
#        for (( i=1; i<${#arg}; i++ )); do
#            args+=("-${arg:$i:1}")
#        done
#    else
#        args+=($arg)
#    fi
#done

#end of pre parse arguments

while [ $# -ne 0 ] ; do
    case $1 in
        --message|-m)
            option_message="$2"
            shift
            shift
            ;;
        --verbose|-v)
            option_verbose=true
            shift
            ;;
        --version|-V)
            echo "$VERSION"
            exit
            ;;
        --help|-h)
            usage
            exit
            ;;
        -*)
            echo "invalid option $1"
            exit 1
            ;;
        *)
            if [[ ! -z "$command" ]] ; then
                echo "command already specified"
                exit 1
            fi

            command=$1
            shift
    esac
done

[[ -z "$command" ]] && echo "no command specified" && exit 1

source_config
ensure_tmp

case $command in
    edit)
        command_edit
        ;;
    list)
        command_list
        ;;
    status)
        command_status
        ;;
    check)
        command_check
        ;;
    update)
        command_update
        ;;
    commit)
        command_commit
        ;;
    push)
        command_push
        ;;
    full)
        command_update
        command_commit
        command_push
        ;;
    *)
        echo "unknown command"
        exit 1
        ;;
esac
