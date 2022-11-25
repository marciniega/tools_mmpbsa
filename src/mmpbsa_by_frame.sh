#!/usr/bin/env bash
set -e

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

trjfile=$1
mdl=$2
base=`pwd`
mkdir f"$mdl"
cd  f"$mdl"
boxdim="CRYST1   10000.0   10000.0  10000.0  90.00  90.00  90.00 P 1           1"
awk -v t="$mdl" -v bd="$boxdim" 'BEGIN{print bd}
                                 (/^MODEL/&&$2==t){f=1;next}(f&&/ENDMDL/){exit}f' ../"$trjfile" > f.pdb
sed 's/OC2/OXT/g' f.pdb | sed 's/OC1/O  /g' > g
mv g f.pdb

bash "$pth2src"/our_mm_special.sh f.pdb
bash "$pth2src"/our_apolar_special.sh f.pdb 
bash "$pth2src"/our_polar_special.sh f.pdb
if [ "$?" != "0"  ];then
   echo "Something went wrong with our_polar_special.sh"
   exit "$?"
fi
cd $base
