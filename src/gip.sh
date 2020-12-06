#!/bin/bash

# gip - git based backup system

VERSION=1.1.0

eval GIP_CONFIG="~/.config/gip/gip"

source "gip_secure.sh"

source_config() {
    if [[ ! -f "$GIP_CONFIG" ]] ; then
            echo "missing config file"
            exit 1
    fi

    source "$GIP_CONFIG"

    eval GIP_PUB="$GIP_PUB"
}

ensure_tmp() {
    if [[ -z "$GIP_REMOTE" ]] ; then
        echo "GIP_REMOTE not specified"
        exit 1
    fi

    if [[ ! -d "$GIP_TMP/.git" ]] ; then
        mkdir -p "$GIP_TMP"

        if [[ -z "$option_verbose" ]] ; then
            git clone --quiet $GIP_REMOTE "$GIP_TMP" > /dev/null
        else
            git clone $GIP_REMOTE "$GIP_TMP"
        fi
    fi
}

command_add() {
    if [[ -z "$GIP_TARGETS" ]] ; then
        echo "missing target(s)"
        exit 1
    fi

    for target in "${GIP_TARGETS[@]}" ; do
        for file in "${GIP_FILES[@]}" ; do
            if [[ "$file" = "$target" ]] ; then
                echo "target $target already exists"
                exit 2
            fi
        done
    done

    # all targets passed, now add

    for target in "${GIP_TARGETS[@]}" ; do
        echo "GIP_FILES+=(\"$target\")" >> $GIP_CONFIG

        if [[ ! -z "$option_secure" ]] ; then
            echo "GIP_SECURE+=(\"$target\")" >> $GIP_CONFIG
        fi
    done
}

command_config() {
    #here we could add --write for $EDITOR and otherwise read with cat or less
	"$EDITOR" "$GIP_CONFIG"
}

command_list() {
    for file in "${GIP_FILES[@]}" ; do
        if [[ ! -z "`gip_is_secure $file`" ]] ; then
            echo -n "SECURE "
        else
            echo -n "       "
        fi
        echo "$file"
    done
}

command_check() {
    for file in "${GIP_FILES[@]}" ; do
        if [[ ! -f "$file" ]] ; then
            echo "$file not found"
            has_error="yes"
        fi
    done

    if [[ ! -z "$has_error" ]] ; then
        exit 1
    fi
}

command_update() {
    command_check

    for file in "${GIP_FILES[@]}" ; do
        if [[ ! -z "$option_verbose" ]] ; then
            echo  "$file => $TMP_DIR/${file#/}"
        fi

        # we create directory before encryption

        mkdir -p "$(dirname "$TMP_DIR/${file#/}")"
    
        if [[ -z "`gip_is_secure $file`" ]] ; then
            cp "$file" "$GIP_TMP/${file#/}"
        else
            gip_secure "$file" "$GIP_TMP/${file#/}"
        fi
    done
}

command_commit() {
    if [[ -z "$option_message" ]] ; then
        option_message="gip commit"
    fi

    if [[ -z "$option_verbose" ]] ; then
        pushd "$GIP_TMP" > /dev/null
        git add . > /dev/null
        git commit -am "$option_message" > /dev/null
        popd > /dev/null
    else
        pushd "$GIP_TMP"
        git add .
        git commit -am "$option_message"
        popd
    fi
}

command_push() {
    if [[ -z "$option_verbose" ]] ; then
        pushd "$GIP_TMP" > /dev/null
        git push > /dev/null
        popd > /dev/null
    else
        pushd "$GIP_TMP"
        git push
        popd
    fi
}

command_status() {
    if [[ -z "$option_verbose" ]] ; then
        pushd "$GIP_TMP" > /dev/null
        git status
        popd > /dev/null
    else
        pushd "$GIP_TMP"
        git status
        popd
    fi
}

usage() {
    echo "Usage: gip [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo -e "\tadd [TARGET]    Add target(s) to the GIP_FILES variables"
    echo -e "\tconfig          Use system editor to edit config file"
    echo -e "\tlist            List GIP_FILES variable"
    echo -e "\tstatus          Show status"
    echo -e "\tcheck           Check if configured files exists"
    echo -e "\tupdate          Check and update files (copies configured files to the tmp dir)"
    echo -e "\tcommit          Create local commit"
    echo -e "\tpush            Push commits to git"
    echo -e "\tfull            Same as 'gip update && gip commit && gip push'"
    echo ""
    echo "Options:"
    echo -e "\t-s|--secure     Move target(s) to  the GIP_SECURE variable"
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
        --secure|-s)
            option_secure="yes"
            shift
            shift
            ;;
        --message|-m)
            option_message="$2"
            shift
            shift
            ;;
        --verbose|-v)
            option_verbose="yes"
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
            if [[ -z "$GIP_COMMAND" ]] ; then
                GIP_COMMAND=$1
            else
                GIP_TARGETS+=("$1")
            fi

            shift
    esac
done

# todo nothing means todo nothing
[[ -z "$GIP_COMMAND" ]] && exit 1

source_config
ensure_tmp

case $GIP_COMMAND in
    add)
        command_add
        ;;
    config)
        command_config
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
        echo "unknown command '$1'"
        exit 1
        ;;
esac
