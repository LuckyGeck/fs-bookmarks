#!/usr/bin/env bash

BMCFG="$HOME/.bmcfg"
BMCFG_TMP="$HOME/.bmcfg_tmp"

touch "$BMCFG"

_refresh_dir_exports() {
    while read -r line; do
      KEY="$(awk -F ':' '{ print $1 }' <<< "$line")"
      VALUE="$(awk -F ':' '{ print $2 }' <<< "$line")"
      export DIR_"$KEY"="$VALUE"
    done < "$BMCFG"
}

_validate_label() {
    if [ -z "$1" ]; then
        echo "Label name should be set for this command!" 1>&2
        return 1
    fi
    if [ -n "${1//[^:]}" ]; then
        echo "Label name '$1' can not have ':' in it!" 1>&2
        return 1
    fi
}

save() {
    _validate_label "$1" || return 1
    delete "$1" && echo "$1:$(pwd)" >> "$BMCFG"
    export DIR_"$1"="$(pwd)"
}

go() {
    _validate_label "$1" || return 1
    local label_path
    label_path=$(awk -F ':' "{ if (\$1 == \"$1\") printf \$2 }" "$BMCFG")
    [ -n "$label_path" ] && cd "$label_path" || return 1
}

print() {
    _validate_label "$1" || return 1
    awk -F ':' "{ if (\$1 == \"$1\") printf \"\033[1;34m\" \$2 \"\033[0m\n\" }" "$BMCFG"
}

delete() {
    _validate_label "$1" || return 1
    awk -F ':' "{ if (\$1 != \"$1\") print }" "$BMCFG" > "$BMCFG_TMP" && mv "$BMCFG_TMP" "$BMCFG"
    unset DIR_"$1"
}

list() {
    awk -F ':' "{ printf \"\033[1;32m\" \$1 \"\033[0m -> \033[1;34m\" \$2 \"\033[0m\n\" }" "$BMCFG"
}

## COMPLETION FUNCTIONS ##

_complete_label_name() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local labels
    labels=$(awk -F ':' '{ printf "\"" $1 "\" " }' "$BMCFG")
    COMPREPLY=( $(compgen -W "$labels" -- "$cur") )
}

complete -F _complete_label_name go print delete list g p d l

## ALIASES FOR MAIN FUNCTIONS ##

alias s=save
alias g=go
alias p=print
alias d=delete
alias l=list

_refresh_dir_exports
