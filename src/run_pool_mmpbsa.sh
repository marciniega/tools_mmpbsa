#!/usr/bin/env bash

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh
. "$pth2lib"/job_pool.sh

trjfile=$1
nprocess=$2

nmdl=`grep -c MODEL y.pdb`

job_pool_init "$2" 0
for mdl in `seq 1 "$nmdl"` ; do
   job_pool_run "$pth2src"/mmpbsa_by_frame.sh "$trjfile" "$mdl"
done
job_pool_wait
job_pool_shutdown

exit "${job_pool_nerrors}"

