#!/bin/bash
pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

trjfile=$1

radare=0.140
radvol=0.129
const_ar1=0.02267
const_ar0=3.84928
const_vol=0.234304
tprfile="../y.tpr"
ndxfile="../y.ndx"

checkfile "$trjfile"
checkfile "$tprfile"
checkfile "$ndxfile"

gmx sasa -f "$trjfile" -tv vvvv.xvg -surface 0 -s "$tprfile" -probe "$radvol" -xvg none >/dev/null 2>&1 
awk -v cv="$const_vol" 'BEGIN{print "apolar_sav"}
                        {print ($2*cv*1000)}' vvvv.xvg > our_sav.xvg
rm area.xvg
gmx sasa -f "$trjfile" -o  aaaa.xvg -surface 0 -s "$tprfile" -probe "$radare" -xvg none >/dev/null 2>&1 
awk -v c0="$const_ar0" -v c1="$const_ar1" 'BEGIN{print "apolar_sas"}
                                           {print ($2*c1*100)+c0}' aaaa.xvg > our_sas.xvg 

rm vvvv.xvg  aaaa.xvg
