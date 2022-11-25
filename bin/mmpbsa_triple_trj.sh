#!/usr/bin/env bash
set -e

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

script_name=mmpbsa_triple_trj.sh

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
        echo "The pair file must be comprised by three lines. Each of these"
        echo "containing three columns:" 
        echo "     1) the name of the group of interest as it appears in the index file."
        echo "     2) The basename of the topology file ( Example: topol_XXX.itp ; XXX is the basename.)."
        echo "        If multple topologies form the group, then add them with \":\"  (Example: XXX:YYY)."
        echo "     3) the path to the folder with the correspoding data (ligand, receptor, complex)."
        echo "The topolgies groups listed in the file must follow the order of appearence in corresponding tpr/gro/top file."
        echo "Example of the pair file:"
        echo "receptor  Protein_chain_A:Protein_chain_B 5jmo_ab.pdb_amber99sb-ildn_300_md/6_Production/1st_run"
        echo "ligand    my_lig:Ion_chain_C              5jmo_ag.pdb_amber99sb-ildn_300_md/6_Production/1st_run"
        echo "complex   Protein_chain_A:Protein_chain_B:my_lig:Ion_chain_C   5jmo_co.pdb_amber99sb-ildn_300_md/6_Production/1st_run"
        echo " "
        echo " The complex line allways at the end of the file."
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

if [ -z "$cor" ]; then cor=`nproc | awk '{print $1/2}'` ; fi
checkfile "$par"
dict_out=(ag ab co)

cur=`pwd`
for i in 1 2 3; do
   outname="${dict_out[((i-1))]}"
   grp=`awk -v t="$i" '(NR==t){print $1}' "$par"`
   top=`awk -v t="$i" '(NR==t){print $2}' "$par"`
   pat=`awk -v t="$i" '(NR==t){print $3}' "$par"`
   cd "$pat"
   echo "traj        : " ${trj?"Option --trj is required"}
   echo "ndx         : " ${ndx?"Option --ndx is required"}
   echo "itp folder  : " ${itp?"Option --itp is required"}
   echo "par         : " ${par?"Option --par is required"}
   checkfile "$trj"
   checkfile "$ndx"
   for ti in `echo "$top" | awk -F":" '{for (x=1;x<=NF;x++){print $x}}'`; do checkfile "$itp"/topol_"$ti".itp; done
   bash "$pth2src"/mmpbsa_main.sh -f "$trj" -o "$outname" -n "$ndx" -s "$tpr" -i "$itp" -g "$grp" -c "$cor" -t "$top"
   mv mmpbsa_"$outname".xvg "$cur"
   cd "$cur"
done
awk '(NR>FNR){l=NR-1}
     (NR==FNR){mmag[$1]=$2;vdwag[$1]=$3;eleag[$1]=$4;polag[$1]=$5;sasag[$1]=$6;savag[$1]=$7;next}
     (NR-FNR-l==0&&!(NR==FNR)){f++}
     (f==1){mmab[$1]=$2;vdwab[$1]=$3;eleab[$1]=$4;polab[$1]=$5;sasab[$1]=$6;savab[$1]=$7}
     (f==2){mmco[$1]=$2;vdwco[$1]=$3;eleco[$1]=$4;polco[$1]=$5;sasco[$1]=$6;savco[$1]=$7}
     END{printf "%-8s%10s%10s%10s%10s%15s%15s\n","#Frame",mmco[0],vdwco[0],eleco[0],polco[0],sasco[0],savco[0];
         for (x=1;x<FNR;x++) { 
         mm=mmco[x]- mmag[x]- mmab[x] ; 
         vdw=vdwco[x]-vdwag[x]-vdwab[x];
         ele=eleco[x]-eleag[x]-eleab[x];
         pol=polco[x]-polag[x]-polab[x];
         sas=sasco[x]-sasag[x]-sasab[x];
         sav=savco[x]-savag[x]-savab[x];
         printf "%-8s%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",x,mm,vdw,ele,pol,sas,sav}
     }' mmpbsa_ag.xvg mmpbsa_ab.xvg mmpbsa_co.xvg > mmpbsa_enthalpy.xvg

