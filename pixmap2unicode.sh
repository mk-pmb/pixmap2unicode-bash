#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function pm2u_init () {
  local -A CHARS=(
    # e = empty, t = top, b = bottom, f = full
    [b]='▄'
    [be]='▖'
    [bt]='▞'
    [e]=' '
    [eb]='▗'
    [et]='▝'
    [f]='█'
    [fb]='▙'
    [ft]='▛'
    [t]='▀'
    [tb]='▚'
    [te]='▘'
    [tf]='▜'
    )

  local -A CFG=(
    [style]='halves'
    )
  local KEY= VAL=
  while [ "$#" -ge 1 ]; do
    VAL="$1"; shift
    if [ "$KEY" != -- ]; then
      KEY=
      case "$VAL" in
        - ) KEY=file;;
        -- ) KEY="$VAL"; continue;;
        --*=* ) pm2u_setopt "${VAL#--}" || return $?; continue;;
        -* ) echo "E: Unsupported option: '$VAL'" >&2; return 4;;
        * ) KEY=file;;
      esac
    fi
    case "$KEY" in
      file | -- ) pm2u_convert_one_file "$VAL" || return $?; continue;;
      * ) echo "E: Unexpected control flow for '$VAL'" >&2; return 8;;
    esac
  done
}


function pm2u_setopt () {
  local KEY="${1%%=*}" VAL="${1#*=}"
  [[ " ${!CFG[*]} " == *" $KEY "* ]] || return 4$(
    echo "E: Unsupported option: '$1'" >&2)
  CFG["$KEY"]="$VAL"
}


function pm2u_convert_one_file () {
  local PM=()
  readarray -t PM < <(convert "$1" -compress none pbm:-)
  case "${PM[0]}" in
    P1 ) PM=( "${PM[@]:2}" );;
    * )
      echo "E: Conversion failed for '$1': Unexpected output syntax" >&2
      return 8;;
  esac

  local UNEXP="${PM[*]}"
  UNEXP="${UNEXP//[01 ]/}"
  [ -z "$UNEXP" ] || return 8$(
    echo "E: Unexpected characters in pixmap output: '$UNEXP'" >&2)

  local ROW_NUM=0
  local ROW_BUF=()

  while [ "${#PM[@]}" -ge 1 ]; do
    (( ROW_NUM += 1 ))
    ROW_BUF=( ${PM[0]} ); PM=( "${PM[@]:1}" )
    case "${CFG[style]}" in
      halves ) pm2u_merge_next_row || return $?;;
    esac
    echo "$ROW_NUM"$'\t'":${ROW_BUF[*]}:"
  done
}


function pm2u_merge_next_row () {
  local NX_ROW=( ${PM[0]} ); PM=( "${PM[@]:1}" )
  local IDX=0 DUMMY=
  for DUMMY in ${ROW_BUF[@]}; do
    ROW_BUF[$IDX]+="${NX_ROW[$IDX]:-0}"
    (( IDX += 1 ))
  done
}










pm2u_init "$@"; exit $?
