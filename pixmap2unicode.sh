#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function pm2u_init () {
  local -A CFG=(
    # e = empty, t = top, b = bottom, f = full
    [c:b]='▄'
    [c:be]='▖'
    [c:bt]='▞'
    [c:e]=' '
    [c:eb]='▗'
    [c:et]='▝'
    [c:f]='█'
    [c:fb]='▙'
    [c:ft]='▛'
    [c:t]='▀'
    [c:tb]='▚'
    [c:te]='▘'
    [c:tf]='▜'

    [style]='halves'
    [rownumfmt]='% 1u\t'
    [siderails]=':'
    )

  local KEY= VAL=
  while [ "$#" -ge 1 ]; do
    VAL="$1"; shift
    if [ "$KEY" != -- ]; then
      KEY=
      case "$VAL" in
        - ) KEY=file;;
        -- ) KEY="$VAL"; continue;;
        -E ) CFG[c:e]='  '; continue;;
        --bare ) CFG[rownumfmt]=; CFG[siderails]=; continue;;
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
  local ROW_BUF= PX=
  while [ "${#PM[@]}" -ge 1 ]; do
    (( ROW_NUM += 1 ))
    ROW_BUF="${PM[0]}"; PM=( "${PM[@]:1}" )
    case "${CFG[style]}" in
      halves ) pm2u_merge_next_row || return $?;;
    esac
    [ -z "${CFG[rownumfmt]}" ] || printf "${CFG[rownumfmt]}" "$ROW_NUM"
    echo -n "${CFG[siderails]}"
    ROW_BUF=" ${ROW_BUF// /  } "
    pm2u_render_"${CFG[style]}" || return $?
    for PX in $ROW_BUF; do
      echo -n "${CFG[c:$PX]:-<? $PX ?>}"
    done
    echo "${CFG[siderails]}"
  done
}


function pm2u_merge_next_row () {
  local NX_ROW=( ${PM[0]} ); PM=( "${PM[@]:1}" )
  local ORIG= MERGED= IDX=0
  for ORIG in $ROW_BUF; do
    MERGED+="$ORIG${NX_ROW[$IDX]:-0} "
    (( IDX += 1 ))
  done
  ROW_BUF="${MERGED% }"
}


function pm2u_render_halves () {
  ROW_BUF="${ROW_BUF// 00 / e }"
  ROW_BUF="${ROW_BUF// 01 / b }"
  ROW_BUF="${ROW_BUF// 10 / t }"
  ROW_BUF="${ROW_BUF// 11 / f }"
}


function pm2u_render_big () {
  ROW_BUF="${ROW_BUF// 0 / e e }"
  ROW_BUF="${ROW_BUF// 1 / f f }"
}










pm2u_init "$@"; exit $?
