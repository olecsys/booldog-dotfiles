#!/usr/bin/env bash

check_executable_exists() {
  command -v "$1" > /dev/null 2>&1
}

run_ssh_agent() {
  local log_filename=$1
  if check_executable_exists ssh-agent; then
    if [ -z "$SSH_AUTH_SOCK" ]
    then
      # Check for a currently running instance of the agent
      local RUNNING_AGENT=
      RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
      [ "$RUNNING_AGENT" = "0" ] && ssh-agent -s &> "${HOME}/.ssh/ssh-agent"
      eval `cat ${HOME}/.ssh/ssh-agent`
    fi
  fi
}

main() {  
  local old_dir="`pwd`/`basename "$0"`"
  old_dir=`dirname "$old_dir"`

  local log_filename=/tmp/booldogrc.sh.log
  
  while true
  do
    echo -e "\n$(date +%Y-%m-%dT%H-%M-%S) - booldogrc.sh is starting" >> "${log_filename}"

    run_ssh_agent "${log_filename}"

    if check_executable_exists ssh-add; then
      [ -f "${HOME}/.ssh/id_rsa" ] && ssh-add "${HOME}/.ssh/id_rsa"
    fi

    # [ -d "$HOME/sources/epiphan/trunk" ] && echo 'EXISTS2'
#     # export EPI_TRUNK="${HOME}/sources/epiphan/trunk"
    if check_executable_exists optirun; then
      alias opera='optirun opera'
      alias code='optirun code'
    fi

    if check_executable_exists "${HOME}/SQLiteStudio/sqlitestudio"; then
      alias sqlitestudio="${HOME}/SQLiteStudio/sqlitestudio"
    fi

    if check_executable_exists "${HOME}/GOGS/build_qml/qvideoclient"; then
      alias qvideoclient-debug='INTEGRA_S_VIDEO_LOG_WRITE_HOME_ALLOW=1 INTEGRA_S_VIDEO_LOG_PATH="'${HOME}'/GOGS/build_qml/log" MJSONDBGDISABLE="1" LD_PRELOAD='${HOME}'/GOGS/build_qml/libhookmem.so '${HOME}'/GOGS/build_qml/qvideoclient'
    fi

    if check_executable_exists "${HOME}/GOGS/build_server/video-server-7.0"; then
      alias videoserver-debug='INTEGRA_S_VIDEO_LOG_WRITE_HOME_ALLOW=1 INTEGRA_S_VIDEO_LOG_PATH="'${HOME}'/GOGS/build_server/log" MJSONDBGDISABLE="1" '${HOME}'/GOGS/build_server/video-server-7.0'
    fi

    if check_executable_exists "${HOME}/GOGS/build_qml/qvideoclient"; then
      alias qvideoclient-top='top -p `pgrep "qvideoclient"`'
    fi

#     # alias code='GTK_IM_MODULE=ibus code'    

    break
  done  
  
  cd "$old_dir"
}
main $@
