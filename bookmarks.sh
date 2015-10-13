#!/usr/bin/env bash

BMCFG="$HOME/.bmcfg"
BMCFG_TMP="$HOME/.bmcfg_tmp"

touch "$BMCFG"

function _validate_label
{
    if [ -z "$1" ]; then echo "Label name should be set for this command!" && return 1; fi;
    if [ -n "${1//[^:]}" ]; then echo "Label name '$1' can not have ':' in it!" && return 1; fi;
}

function save
{
    _validate_label "$1" || return 1
    delete "$1" && echo "$1:$(pwd)" >> "$BMCFG"
}

function go
{
    _validate_label "$1" || return 1
    LABEL_PATH=$(awk -F ':' "{ if (\$1 == \"$1\") printf \$2 }" "$BMCFG")
    [ -n "$LABEL_PATH" ] && cd "$LABEL_PATH"
}

function print
{
    _validate_label "$1" || return 1
    awk -F ':' "{ if (\$1 == \"$1\") printf \"\033[1;34m\" \$2 \"\033[0m\n\" }" "$BMCFG"
}

function delete
{
    _validate_label "$1" || return 1
    awk -F ':' "{ if (\$1 != \"$1\") print }" "$BMCFG" > "$BMCFG_TMP" && mv "$BMCFG_TMP" "$BMCFG"
}

function list
{
    awk -F ':' "{ printf \"\033[1;32m\" \$1 \"\033[0m -> \033[1;34m\" \$2 \"\033[0m\n\" }" "$BMCFG"
}

alias s=save
alias g=go
alias p=print
alias d=delete
alias l=list