#!/bin/bash

# gip_is_secure returns yes if target is secure 

gip_is_secure() {
    if [[ -z "$1" ]] ; then
        echo "cannot secure no target"
        exit 1
    fi

    for secure in "${GIP_SECURE[@]}" ; do
        if [[ "$secure" = "$1" ]] ; then
            echo "$secure"
        fi 
    done
}

# gip_secure encrypes target to destination with the use of $GIP_PUB

gip_secure() {
    if [[ -z "$1" ]] ; then
        echo "cannot secure no target"
        exit 1
    fi

    if [[ -z "$2" ]] ; then
        echo "no out specified"
        exit 2
    fi

    if [[ ! -f "$GIP_KEY" ]] ; then
        echo "GIP_PUB not found"
        exit 3
    fi

    openssl enc -aes-256-cbc -md sha512 -in "$1" -k "$GIP_KEY" -out "$2"
}