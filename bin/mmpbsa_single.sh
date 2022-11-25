#!/usr/bin/env bash
set -e

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

script_name=mmpbsa_single.sh

example() {
	echo -e "example of use: $script_name -f trj.xtc -n index.ndx -s topol.tpr -i itps -p pair_file.txt -c 24\n" 
}

show_help() {
	echo "-f --trj  	Trajectory file. "
	echo "-n --ndx 		Index file. "
	echo "-s --tpr 		MD compiled file. "
        echo "-i --itp          Directory containing the itp files. "
        echo "-p --par          File listing the pair of molecules. "
        echo "-c --cor          Number of cores to use. "
        echo " "
        echo "The pair file must be comprised by one line"
        echo "containing two columns:" 
        echo "     1) the name of the group of interest as it appears in the index file."
        echo "     2) The basename of the topology file ( Example: topol_XXX.itp ; XXX is the basename.)."
        echo "        If multple topologies form the group, then add them with \":\"  (Example: XXX:YYY)."
        echo "The two groups listed in the file must follow the order of appearence in tpr/gro/top file."
        echo "Example of the pair file:"
        echo "receptor  Protein_chain_A:Protein_chain_B"
        echo " "
	example
}

if [[ $# -eq 0 ]]; then
	echo -e "\n$script_name: This script needs arguments.\n"
        show_help
        echo ""
        exit 1
fi

while [[ $# -gt 0 ]]; do
	case $1 in
		-f | --trj ) shift
				trj=$1
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
		-p | --par ) shift
				par=$1
					;;
		-c | --cor ) shift
				cor=$1
					;;
		-h | --help ) show_help
				exit
					;;
		*)
		echo -e "\n$script_name: illegal option $1\n"
                echo -e "Try with option \"-h\" to get help.\n"
		example
		exit 1
					;;
	esac
	shift
done
echo "traj        : " ${trj?"Option --trj is required"}
echo "ndx         : " ${ndx?"Option --ndx is required"}
echo "itp folder  : " ${itp?"Option --itp is required"}
echo "pari        : " ${par?"Option --par is required"}
if [ -z "$cor" ]; then cor=`nproc | awk '{print $1/2}'` ; fi
checkfile "$trj"
checkfile "$ndx"
checkfile "$par"
grp1=`awk '(NR==1){print $1}' "$par"`
top1=`awk '(NR==1){print $2}' "$par"`

for ti in `echo "$top1" | awk -F":" '{for (x=1;x<=NF;x++){print $x}}'`; do checkfile "$itp"/topol_"$ti".itp; done

bash "$pth2src"/mmpbsa_main.sh -f "$trj" -o 0 -n "$ndx" -s "$tpr" -i "$itp" -g "$grp1" -c "$cor" -t "$top1"
