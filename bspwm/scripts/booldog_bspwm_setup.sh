#!/usr/bin/env bash

function setup_dual_monitors() {
    true
}
function check_executable_exists() {
  command -v "$1" > /dev/null 2>&1
}
function user_input_confirmation_default_no() {
  local __question=$1

  local __text=$(echo -e "${__question} (y/N)")
  read -p "${__text}" -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && return 1 || return 0
}
function main() {
  local old_dir="`pwd`/`basename "$0"`"
  old_dir=`dirname "$old_dir"`
  cd "`dirname "$0"`"
  local script_dir="`pwd`/`basename "$0"`"
  script_dir=`dirname "$script_dir"`
  cd "$old_dir"

  local red='\e[0;31m'
  local green='\e[0;32m'
  local nocolor='\e[0m'
  local redbold='\e[1;31m'
  local greenbold='\e[1;32m'
  local nocolorbold='\e[1m'

  local __cmd_args=( "$@" )

  local __funcerror=     # set `__funcerror` variable with custom error message 
  local __funcresult=1   # set `__funcresult` variable with script result

  while true
  do
    echo -e "\n$(date +%Y-%m-%dT%H-%M-%S) - Setup monitors" >> /tmp/booldog.log

    local __pattern=connected
    # local __pattern=disconnected # test mode
    local __connected_monitors=($(xrandr --query|grep -E '.+\s'${__pattern}|sed 's/^\(.\+\)\s'${__pattern}'.*$/\1/g'))

    local __resolutions=($(xrandr --query|grep -E '.+\s'${__pattern}|sed 's/^\(.\+\)\s'${__pattern}'\s\(primary\s\)*\([0-9]\+x[0-9]\+\).*$/\3/g'))

    __pattern=^LVDS[0-9]+$
    # __pattern=^DVI-I-[0-9]+$
    local i
    local __laptop=
    for ((i=0; i<${#__connected_monitors[@]}; i++))
    do
      if [[ ${__connected_monitors[i]} =~ ${__pattern} ]]; then
        __laptop=${__connected_monitors[i]}
      fi
    done        
    if [ -z "${__laptop}" ]; then
      __pattern=^HDMI[0-9]+$
      local __laptop=
      for ((i=0; i<${#__connected_monitors[@]}; i++))
      do
        if [[ ${__connected_monitors[i]} =~ ${__pattern} ]]; then
          __laptop=${__connected_monitors[i]}
        fi
      done        
    fi

    if [ ! -z "${__laptop}" ]; then
      xrandr --output ${__laptop} --primary --auto || break      
      local __monitor_index=0
      for ((i=0; i<${#__connected_monitors[@]}; i++))
      do
        if ! [ "${__connected_monitors[i]}" = "${__laptop}" ]; then
          local __position=--left-of\ ${__laptop}
          [ $__monitor_index -eq 1 ] && __position=--right-of\ ${__laptop}
          xrandr --output ${__connected_monitors[i]} --auto ${__position} \
            || { __funcresult=2 ; break; }
          local __monitor_index=$(expr $__monitor_index + 1)
        fi        
      done
    fi    

    [ $__funcresult -eq 2 ] && break

    if [ ${#__connected_monitors[@]} -gt 1 ]; then
      for ((i=0; i<${#__connected_monitors[@]}; i++))
      do
        if ! [ "${__connected_monitors[i]}" = "${__laptop}" ]; then
          bspc monitor ${__connected_monitors[i]} -d dev chat
        else
          bspc monitor ${__connected_monitors[i]} -d web
        fi        
      done
    else
      bspc monitor ${__connected_monitors[0]} -d dev chat web
    fi

    if check_executable_exists setxkbmap; then
      local __result=$(setxkbmap -layout us,ru -option "grp:alt_shift_toggle,grp_led:scroll") \
        || echo -e "\n$(date +%Y-%m-%dT%H-%M-%S) - ${__result}" >> /tmp/booldog.log
      # setxkbmap -layout 'us'
      # setxkbmap -option compose:menu

      # For the key chord that performs the layout switching between US
      # QWERTY and Greek see my `sxhkdrc`.  The script:
      # `own_script_current_keyboard_layout`
    else
      echo -e "\n$(date +%Y-%m-%dT%H-%M-%S) - Cannot find setxkmap" >> /tmp/booldog.log
    fi

    __funcresult=0
    break
  done  
  
  cd "$old_dir"

  while true
  do
    [ ! -z "$__funcerror" ] \
        && { echo -e "
${red}${__funcerror}${nocolor}
" 1>&2 ; __funcresult=1 ; break; }
    
    [ $__funcresult -eq 0 ] \
        && { echo -e '
'${greenbold}'booldog bspwm'${green}' setup is succeeded
'${nocolor} ; break; }
        
    echo -e '
'${redbold}'booldog bspwm'${red}' setup is failed
'${nocolor} 1>&2
    
    break
  done

  exit $__funcresult
}
main $@