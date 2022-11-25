#/usr/bin/env bash
set -a
pth2main=/shared/software/tools_mmpbsa
pth2src="$pth2main"/src
pth2lib="$pth2main"/lib

apbs_template="$pth2lib"/apbs_mol_template.in
atmchrgrad="$pth2lib"/AMBER.DAT
recalc_mdp="$pth2lib"/recalc.mdp
byresfile="$pth2lib"/recalc_by_res.mdp
byresgrp="$pth2lib"/by_res_vdw_ele.txt
get_ndx_from_gro="$pth2src"/get_ndx_from_gro.sh 
setup_apbs_files="$pth2src"/setup_apbs_from_pdbtrj.sh
set +a
