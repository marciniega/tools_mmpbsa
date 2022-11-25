#!/bin/bash
grofile=$1

awk -v f=0 '(substr($0,14,2)=="CA"||(substr($0,15,1)=="N"&&/NME/)||(substr($0,15,1)=="C"&&/ACE/)){c++;ri=substr($1,1,length($1)-3); 
                                                     if (f==0){f=1;x=ri;a[c]=x;next}; 
                                                     if (ri==x+1){x=ri;next}else{a[c-1]=x;a[c]=ri;x=ri}}
            END{a[c]=ri; for (k in a) print k,a[k]}' "$grofile" | sort -nk1 > relations_molecule.txt


awk 'BEGIN{print "del 1-20\n0\nname 1 Protein\n1 &! a H*\nname 2 Protein-H\n0 & a CA\nname 3 alphas"}
     (NR%2){printf "ri %s-",$1}
     !(NR%2){c++;printf "%s\nname %s chain_%s\n",$1,(3+c),c}
     END{for (k=4;k<=c+3;k++) printf "%s & 3\n",k;print "q"}' relations_molecule.txt > g

gmx make_ndx -f "$grofile" -o y.ndx < g >/dev/null 2>&1
rm g
