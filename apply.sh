#!/bin/bash

# requirements:
# pacman -S polybar

function read_options() {
  g_opt_ind=0
  while getopts "yYnN" opt; do
    glob_opt_args[$g_opt_ind]=$opt
    g_opt_ind=$(($g_opt_ind+1))
  done
  g_opt_ind=0
}

function backup_and_copy() {  
  local __src=${1}
  local __backup_dst=${2}
  local __copy_src=${3}

  local __src_dirname=$(dirname "${__src}")

  [ ! -d "${__backup_dst}" ] && { mkdir -p "${__backup_dst}" || return 1; }

  [ -e "${__src}" ] && { mv "${__src}" "${__backup_dst}" || return 1; }

  [ -d "${__copy_src}" ] && { cp -r "${__copy_src}" "${__src_dirname}" || return 1; }

  [ -f "${__copy_src}" ] && { cp "${__copy_src}" "${__src_dirname}" || return 1; }

  return 0
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

  read_options $@  

  local __funcerror=     # set `__funcerror` variable with custom error message 
  local __funccanceled=0 # if you want to cancel script set to `1`
  local __funcresult=1   # set `__funcresult` variable with script result

  while true
  do
    # add main logic here 
    local __now_date=$(date +"%Y-%m-%d")
    local __now_time=$(date +"%H-%M-%S")

    local __user_config_path="${HOME}/.config"

    local __user_backup_path="${HOME}/.booldog-backup-${__now_date}/${__now_time}"

    local __user_backup_config_path="${__user_backup_path}/.config"

    backup_and_copy "${__user_config_path}/bspwm" "${__user_backup_path}" "${script_dir}/bspwm" \
      || break

    backup_and_copy "${__user_config_path}/polybar" "${__user_backup_path}" "${script_dir}/polybar" \
      || break

    backup_and_copy "${__user_config_path}/sxhkd" "${__user_backup_path}" "${script_dir}/sxhkd" \
      || break

    backup_and_copy "${HOME}/.booldogrc.sh" "${__user_backup_path}" "${script_dir}/.booldogrc.sh" \
      || break

    chmod +x "${HOME}/.booldogrc.sh" || break

    if [ -f "${HOME}/.zshrc" ]; then
      sed -i '/^.*[.]booldogrc[.]sh.*$/d' "${HOME}/.zshrc"
      (
      tee -a "${HOME}/.zshrc" <<EOFBOOLDOG
command -v "${HOME}/.booldogrc.sh" > /dev/null 2>&1 && . "${HOME}/.booldogrc.sh"
EOFBOOLDOG
) || __funcfailed=1
    fi

    __funcresult=0
    break
  done  
  
  cd "$old_dir"

  while true
  do
    [ $__funccanceled -eq 1 ] \
        && { echo -e '
'${redbold}'~/.config'${red}' applying is canceled
'${nocolor} 1>&2 ; break; }

    [ ! -z "$__funcerror" ] \
        && { echo -e "
${red}${__funcerror}${nocolor}
" 1>&2 ; __funcresult=1 ; break; }
    
    [ $__funcresult -eq 0 ] \
        && { echo -e '
'${greenbold}'~/.config'${green}' applying is succeeded
'${nocolor} ; break; }
        
    echo -e '
'${redbold}'~/.config'${red}' applying is failed
'${nocolor} 1>&2
    
    break
  done

  exit $__funcresult
}
main $@