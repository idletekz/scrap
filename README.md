#!/bin/bash

stopme() {
	pidList=$(ps -ef | grep "$PWD/test.sh" | grep -v grep | awk '{print $2}')

	# check empty pidList
	if [ -z "$pidList" ]
	then
		return 0
	fi

	# iterate through the pids
	while read -r pid; do
	  kill $pid
	  # See if you have permission to signal the process. If not,
		# this should result in output similar to:
		#     bash: kill: (15764) - Operation not permitted
		#     Exit status: 1
	  # >/dev/nul ignore the "No such proccess" message after the
	  # proccess was killed	
		while $(kill -0 $pid 2>/dev/null); do
			sleep 1
		done
	done <<< "$pidList"
}

startme() {
	$PWD/test.sh &
}

case "$1" in 
    start)   startme ;;
    stop)    stopme ;;
    restart) stopme; startme ;;
    *) echo "usage: $0 start|stop|restart" >&2
       exit 1
       ;;
esac