#!/bin/bash
pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

trjfile=$1
resatm=$2

radare=0.140
radvol=0.129
const_ar1=0.02267
const_ar0=3.84928
const_vol=0.234304
tprfile="y.tpr"

checkfile "$trjfile"
checkfile "$tprfile"
checkfile "$resatm"

nres=`awk 'END{print NR}' "$resatm"`
for resi in `seq 1 "$nres"` ; do
    awk -v t="$resi" '(NR==t){print "[ xxxx ]";for (x=$1;x<=$2;x++){printf "%s ",x};print ""}' "$resatm" > h.ndx
    #gmx sasa -f "$trjfile" -tv oooo.xvg -surface 0 -s "$tprfile" -probe "$radvol" -xvg none -n h.ndx >/dev/null 2>&1 
    #awk -v cv="$const_vol" '{print ($2*cv*1000)}' oooo.xvg
    #rm area.xvg oooo.xvg
    gmx sasa -f "$trjfile" -o rrrr.xvg -surface 0 -s "$tprfile" -probe "$radare" -xvg none -n h.ndx >/dev/null 2>&1 
    awk -v c1="$const_ar1" -v c0="$const_ar0" '{print ($2*c1*100)+c0}' rrrr.xvg
    rm rrrr.xvg h.ndx 
done
