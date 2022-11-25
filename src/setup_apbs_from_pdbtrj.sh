#!/bin/bash
trjfile=$1
apbs_template=$2
factor=1.6
cgsiz=0.7
fnsiz=0.5


awk '(/^ATOM/||/^HETATM/)' "$trjfile" > tmp.txt
molextrem=(`awk 'BEGIN{xl[0]=1000;xl[1]=-1000;yl[0]=1000;yl[1]=-1000;zl[0]=1000;zl[1]=-1000}
                 {x=strtonum(substr($0,31,8));y=strtonum(substr($0,39,8));z=strtonum(substr($0,47,8))}
                 (x<xl[0]){xl[0]=x}
                 (x>xl[1]){xl[1]=x}
                 (y<yl[0]){yl[0]=y}
                 (y>yl[1]){yl[1]=y}
                 (z<zl[0]){zl[0]=z}
                 (z>zl[1]){zl[1]=z}
                 END{print xl[0],xl[1],yl[0],yl[1],zl[0],zl[1]}' tmp.txt`)
molcenter=(`echo "${molextrem[*]}" | awk '{print ($2-$1)*0.5+$1, ($4-$3)*0.5+$3, ($6-$5)*0.5+$5}'`)
mollenori=(`echo "${molextrem[*]}" | awk '{print ($2-$1), ($4-$3), ($6-$5)}'`)
mollencor=(`echo "${mollenori[*]}" | awk -v a="$factor" -v g="$cgsiz" 'function fit(value){u=g%value;
                                                                                          l=value%g;
                                                                                          d=u-l;
                                                                                          return (value+d)} 
                                                                     {print fit($1*a),fit($2*a),fit($3*a)}'`)
mollenfin=(`echo "${mollenori[*]}" | awk -v a="$factor" -v g="$fnsiz" 'function fit(value){u=g%value;
                                                                                          l=value%g;
                                                                                          d=u-l;
                                                                                          return (value+d)} 
                                                                     {print fit($1*a),fit($2*a),fit($3*a)}'`)
gridlencg=(`echo "${mollencor[*]}" | awk -v a="$cgsiz" '{print $1/a, $2/a, $3/a}'`)
apbsdimcg=(`echo "${gridlencg[*]}" | awk 'function getdim(value){c=33;
                                                                 i=1
                                                                 while (c<value){
                                                                       i++
                                                                       c=(i*32)+1} 
                                                                 return c }
                                          {print getdim($1),getdim($2),getdim($2)}'`)

#echo "${molextrem[*]}" 
#echo "${molcenter[*]}" 
#echo "${mollenori[*]}" "ori"
#echo "${mollencor[*]}" "cor"
#echo "${mollenfin[*]}" "fin"
#echo "${gridlencg[*]}" 
#echo "${apbsdimcg[*]}"

sed "s/DIME_COAR/${apbsdimcg[*]}/g" "$apbs_template" > tmp.in
sed "s/GRID_COAR/$cgsiz $cgsiz $cgsiz/g" tmp.in > mmm.in ; mv mmm.in tmp.in
sed "s/GRID_FINE/$fnsiz $fnsiz $fnsiz/g" tmp.in > mmm.in ; mv mmm.in tmp.in
sed "s/CENTERMOL/${molcenter[*]}/g" tmp.in > apbs_mol_gen.in
rm tmp.in tmp.txt
