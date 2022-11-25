#!/bin/bash

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

trjfile=$1
basename=`echo "$trjfile" | awk -F'.' '{print $1}'`
baseapbsfile="../apbs_mol_gen.in"
chrgrad_file="../atm_chrg_rad.txt"
checkfile "$baseapbsfile"
checkfile "$chrgrad_file"
echo "polar" > our_pol.xvg 
#pdb2pqr30 "$trjfile" "$basename".pqr --assign-only --ff AMBER >/dev/null 2>&1
genpqr "$trjfile" "$basename" "$chrgrad_file"
sed "s/XXX/$basename/g" "$baseapbsfile" > sig"$basename".in
apbs --output-file=o"$basename".out sig"$basename".in > apbs_"$basename".log 2>&1
awk '/totEnergy/{a[f++]=$2}END{print a[3]-a[1]}' o"$basename".out >> our_pol.xvg
rm io.mc "$basename".pqr sig"$basename".in o"$basename".out  apbs_"$basename".log
