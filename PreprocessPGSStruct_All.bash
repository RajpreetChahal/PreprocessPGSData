#!/usr/bin/env bash

#
# run preprocessing for everyone (in PGS)
#  in parallel
#

## job control
MAXJOBS=5
sleeptime=050
function waitforjobs {
	while [ $(jobs -p | wc -l) -ge $MAXJOBS ]; do
		echo "@$MAXJOBS jobs, sleeping $sleeptime s"
		jobs | sed 's/^/\t/'
		sleep $sleeptime
	done
}

scriptdir=$(cd $(dirname $0);pwd)

## actual loop
for subjPGSdir  in $scriptdir/../Upitt/wave6/*; do
	subjdate=$(basename $subjPGSdir)
 $scriptdir/PreprocessPGSStruct.bash $subjdate &
	waitforjobs
done

# wait for everything to finish before saying we're done
wait

