#!/usr/bin/env bash
set -e

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

example() {
	echo -e "example: $script_name -f trj.xtc -o co -c 32 -s topol.tpr -i itps -n index.ndx -g Protein" 
}

show_help() {
	echo "-f --trj  	Trajectory file. "
        echo "-o --out          Suffix to mark the output file. "
	echo "-n --ndx 		Index file [ index.ndx ] "
	echo "-s --tpr 		Topol file [ topol.tpr ] "
        echo "-i --itp          Directory containing the itp files [ . ]  "
        echo "-g --grp          Group ID within the given index file [ Protein ] "
        echo "-t --top          Topology base name "
        echo "-c --cor          Number of cores to use "
	example
}

if [[ $# -eq 0 ]]; then
        echo ""
	echo "$script_name: This script needs arguments."
	echo ""
        show_help
        echo ""
        exit 1
fi

while [[ $# -gt 0 ]]; do
	case $1 in
		-f | --trj ) shift
				trj=$1
					;;
		-o | --out ) shift
				out=$1
					;;
		-n | --ndx ) shift
				ndx=$1
					;;
		-s | --tpr ) shift
				tpr=$1
					;;
		-i | --itp ) shift
				itp=$1
					;;
		-g | --grp ) shift
				grp=$1
					;;
		-c | --cor ) shift
				cor=$1
					;;
		-t | --top ) shift
				top=${1:-"dummy"}
					;;
		-h | --help ) show_help
				exit
					;;
		*)
		echo "$script_name: illegal option $1"
		example
		exit 1
					;;
	esac
	shift
done

if [ -z "$cor" ]; then cor=`nproc | awk '{print $1/2}'` ; fi

bash "$pth2src"/get_y_files.sh "$trj" "$grp" "$top" "$itp" "$ndx" "$tpr"
bash "$pth2src"/run_pool_mmpbsa.sh y.pdb "$cor"

nmdl=`grep -c MODEL y.pdb`
mdl=1
paste f"$mdl"/our_mm.xvg f"$mdl"/our_pol.xvg f"$mdl"/our_sas.xvg f"$mdl"/our_sav.xvg > mmpbsa.xvg 
rm -r f"$mdl"
for mdl in `seq 2 "$nmdl"` ; do
   paste f"$mdl"/our_mm.xvg f"$mdl"/our_pol.xvg f"$mdl"/our_sas.xvg f"$mdl"/our_sav.xvg | tail -1 >> mmpbsa.xvg 
   rm -r f"$mdl"
done
awk '/^#/{print "#Frame  "$0; next}{print NR-1,$0}' mmpbsa.xvg > mmpbsa_"$out".xvg ;

rm y.??? relations_*.txt mmpbsa.xvg apbs_mol_gen.in atm_chrg_rad.txt 
