#!/bin/bash
set -e

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh


trjfile=$1
resatm=$2
const_die=0.5
checkfile "$trjfile"
checkfile "$byresfile"
checkfile "$byresgrp"
checkfile "$resatm"

nres=`awk 'END{print NR}' "$resatm"`
touch pre_our_vdw_by_res.xvg 
touch pre_our_ele_by_res.xvg 
for resi in `seq 1 "$nres"` ; do
    awk -v t="$resi" '(NR==t){print "[ xxxx ]";for (x=$1;x<=$2;x++){printf "%s ",x};print ""}' "$resatm" > x.ndx
    gmx grompp -f "$byresfile" -c y.gro -p y.top -o x.tpr -n x.ndx >/dev/null 2>&1
    gmx mdrun -s x.tpr -rerun "$trjfile" -deffnm xxxx -nt 1 >/dev/null 2>&1
    gmx energy -f xxxx.edr -o xxxx.xvg -xvg none<"$byresgrp" >/dev/null 2>&1
    awk '{vs=$4;v=vs+$2;printf "%12.3f\n",v}' xxxx.xvg >> pre_our_vdw_by_res.xvg
    awk -v cdie="$const_die" '{cs=$5;c=cs+$3;printf "%12.3f\n",c*cdie}' xxxx.xvg >> pre_our_ele_by_res.xvg
    rm xxxx.log xxxx.xvg xxxx.edr x.ndx x.tpr mdout.mdp 
done
