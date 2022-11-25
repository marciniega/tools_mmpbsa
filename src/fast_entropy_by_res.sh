#!/usr/bin/env bash
set -e

function compute_entropy_res () { awk -v kt=2.49434 -v r=$2 -v t=$3 '(NR==1){f=1;v=1;c=0;next}
          						  	(/Frame/&&f!=$2){val[f]=v;f=$2;v=1;c=0;next}
	    							{c++;if (c!=r){v*=$2}}
            							END{val[f]=v;for (x=1;x<=f;x++){sum+=val[x]};
                         					ave=sum/f;
		         					const=-kt*log(f);
		         					print const+(kt*log(ave))-t}' $1 ;}
infile=$1 # inter_energy_decomp.xvg
nres=`awk 'END{print NF-1}' "$infile"`
awk -v kt=2.49434 '(NR==1){for (x=3;x<=NF;x++){n[x-1]=$x}}
                   (NR>1){for (x=2;x<=NF;x++){a[NR][x]=$x}}
	           END{for (x=2;x<=NF;x++){
       	                   for (z=2;z<=NR;z++){
				    ave[x]+=a[z][x]
			   };
		           ave[x]/=(NR-1)};
		       for (z=2;z<=NR;z++){print "Frame "z-1;
				           for (x=2;x<=NF;x++){
						   diff=a[z][x]-ave[x]
						   val=diff/kt
						   print n[x],exp(val)}}}' "$infile" > resi_contrib_by_frame.xvg

entropy_inter=`compute_entropy_res resi_contrib_by_frame.xvg`
echo "$entropy_inter"
res_names=(`awk '/Frame/{f++}(f==2){exit}(f){print $1}' resi_contrib_by_frame.xvg`)
for i in `seq 1 $nres`;do
    echo -n "${res_names["$i"]}   "
    compute_entropy_res resi_contrib_by_frame.xvg "$i" "$entropy_inter"
done > resi_contrib_entropy_excluded.xvg

