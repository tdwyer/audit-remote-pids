#!/bin/bash
#
#
RUN="/var/lib/audit/run"
LOG_PATH="/var/log/audit"
WAIT=13
#
LS=/usr/bin/ls
CAT=/usr/bin/cat
CUT=/usr/bin/cut
DATE=/usr/bin/date
TOUCH=/usr/bin/touch
MKDIR=/usr/bin/mkdir
GREP=/usr/bin/grep
SLEEP=/usr/bin/sleep
#
LDATE=""
LTIME=""
LOG=""
#
PDIR=""
PSTAMP=""
PID=""

main() {
  [[ ! -d ${LOG_PATH} ]] && ${MKDIR} ${LOG_PATH} || clean_logs
  #
  audit_loop &
}

clean_logs() {
  #
  #
  echo 'Clean Out Old Longs - TODO'
}

audit_loop() {
  #
  #
  ${TOUCH} ${RUN}
  #
  while [[ -f ${RUN} ]] ; do
    log_init
    echo "Audit ${LTIME}" >> ${LOG}
    audit
    ${SLEEP} ${WAIT}
  done
  #
  echo "Audit Stoped ${LTIME}" >> ${LOG}
}

log_init() {
  ldate
  ltime
  log_file
  #
  [[ ! -f ${LOG} ]] && ${TOUCH} "${LOG}"
}

ldate() {
  LDATE="$(${DATE} +"%m-%d-%y")"
}

ltime() {
  LTIME="$(${DATE} +"%T:%S")"
}

log_file() {
  LOG="${LOG_PATH}/RemotePIDs-${LDATE}.log"
}

audit() {
  #
  #
  for line in $(dir_list) ; do
    #
    PDIR="${line}"
    #
    if [[ $(check) ]] ;then
      pid "${line}"
      log_process
    fi
    #
  done
}

dir_list() {
  echo -n "$(${LS} -trd1 /proc/[[:digit:]]* | tail -n +50)"
}

check() {
  [[ "$(${CAT} ${PDIR}/ipaddr 2>/dev/null)" != '0.0.0.0' ]] && echo -n 1
}

pid() {
  PID=$(echo -n "${PDIR}" | ${CUT} -d '/' -f 3 2>/dev/null)
}

log_process() {
  #
  #
  process="$(comm)(${PID})"
  host="($(uid))$(ip)"

  [[ ! $(${GREP} "${process}" ${LOG}) && ${host} != "()" ]] && \
    echo "${LTIME} ${process}@${host}" >> ${LOG}
}

comm() {
  echo -n "$(${CAT} ${PDIR}/comm 2>/dev/null)"
}

uid() {
  echo -n "$(${CAT} ${PDIR}/loginuid 2>/dev/null)"
}

ip() {
  echo -n "$(${CAT} ${PDIR}/ipaddr 2>/dev/null)"
}

main
exit 0
# vim: set ts=2 sw=2 tw=80 et :
