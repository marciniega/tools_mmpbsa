#!/bin/bash

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

checkfile "$get_ndx_from_gro"
checkfile "$apbs_template"
checkfile "$recalc_mdp"

reftrj=$1    # Trajectory to work with
usrgrp=$2    # Group in the index file pointing the molecule of interest
topnam=$3    # Topology file [ .top]
diritps=$4   # Folder where the .itp files are stored
refndx=$5    # index group [ .ndx ]
reftpr=$6    # MD process compiled file [ .tpr ] 

if [ -z "$diritps"  ]; then
   diritps="."
fi

checkfile "$reftrj"
checkfile "$refndx"
checkfile "$reftpr"

chns=(`echo "$topnam" | awk -F':' '{for (x=1;x<=NF;x++) print $x}'`)

echo "${chns[@]}" | awk -v d="$diritps" 'BEGIN{print "#include \"amber99sb-ildn.ff/forcefield.itp\""}
                    {for (x=1;x<=NF;x++) print "#include \""d"/topol_"$x".itp\"" }
                    END{print "[ system ]\nDummy\n[ molecules ]"}' > y.top

touch atm_chrg_rad.txt
for i in "${chns[@]}";do
    getcharge "$i" "$diritps" 
    getradius "$i" "$atmchrgrad" 
    cat qr_"$i".txt >> atm_chrg_rad.txt
    rm qr_"$i".txt  q_"$i".txt 
    getmoltyp "$diritps"/topol_"$i".itp >> y.top
done

echo "$usrgrp" | gmx trjconv -f "$reftrj" -s "$reftpr" -n "$refndx" -o r.gro -e 0 >/dev/null 2>&1
checkfile r.gro
echo "$usrgrp" | gmx trjconv -f "$reftrj" -s "$reftpr" -n "$refndx" -o y.xtc  >/dev/null 2>&1
checkfile y.xtc
bash "$get_ndx_from_gro" r.gro
checkfile y.ndx

# Aligning with princ to set the polar computations (APBS).
echo 0 3 0 | gmx editconf -f r.gro -o y.gro -n y.ndx -princ >/dev/null 2>&1 
checkfile y.gro

awk '(NR>1){print last}{last=$0}END{print "    1000   1000   1000"}' y.gro > y.gro.gro
mv y.gro.gro y.gro

gmx grompp -f "$recalc_mdp" -c y.gro -p y.top -o y.tpr >/dev/null 2>&1
checkfile y.tpr
echo 3 0 | gmx trjconv -f y.xtc -s y.gro -o o.xtc -fit rot+trans -n y.ndx >/dev/null 2>&1
echo 0 | gmx trjconv -f o.xtc -s y.tpr -o y.pdb -n y.ndx >/dev/null 2>&1
rm mdout.mdp r.gro o.xtc
fixatnname y.pdb 
checkfile y.pdb
awk -v patn=1 '(/ATOM/||/HETATM/){resi=substr($0,23,4);atn=$2;if (resi!=prev&&atn>1){print patn,atn-1;patn=atn}prev=resi}(/TER/){print patn,atn;exit}' y.pdb > relations_res_atom.txt
bash "$setup_apbs_files" y.pdb "$apbs_template"
checkfile apbs_mol_gen.in
