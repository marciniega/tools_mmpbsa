#!/bin/bash

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

trjfile=$1
const_die=0.5
tprfile="../y.tpr"
ndxfile="../y.ndx"

checkfile "$trjfile"
checkfile "$tprfile"
checkfile "$ndxfile"

gmx mdrun -s "$tprfile" -rerun "$trjfile" -deffnm tttt -nt 1 >/dev/null 2>&1

echo 1 2 3 4 5 6 7 8 | gmx energy -f tttt.edr -o tttt.xvg -xvg none >/dev/null 2>&1

#awk -v cdie=0.5 'BEGIN{print "#mm vdw_sr ele_sr  vdw  ele"} 
#          {m=$2+$3+$4+$5;vs=$8;cs=$9;v=vs+$6;c=cs+$7;
#           printf "%12.3f %12.3f %12.3f %12.3f %12.3f\n",m,vs,cs*cdie,v,c*cdie}' tttt.xvg > our_mm.xvg
awk -v cdie="$const_die" 'BEGIN{print "mm vdw_sr  ele_sr"} 
          {m=$2+$3+$4+$5;vs=$8;cs=$9;
           printf "%12.3f %12.3f %12.3f\n",m,vs,cs*cdie}' tttt.xvg > our_mm.xvg

rm tttt.log tttt.xvg tttt.edr
