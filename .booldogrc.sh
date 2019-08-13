#!/bin/bash

function check_executable_exists() {
  command -v "$1" > /dev/null 2>&1
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
  
  local __funcerror=     # set `__funcerror` variable with custom error message 
  local __funcresult=1   # set `__funcresult` variable with script result

  while true
  do
    if check_executable_exists optirun; then
      alias opera='optirun opera'
      alias code='optirun code'
    fi

    # alias code='GTK_IM_MODULE=ibus code'

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
'${greenbold}'.booldogrc.sh'${green}' initialization is succeeded
'${nocolor} ; break; }
        
    echo -e '
'${redbold}'.booldogrc.sh'${red}' initialization is failed
'${nocolor} 1>&2
    
    break
  done
}
main $@