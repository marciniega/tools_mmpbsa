#!/usr/bin/env bash

function checkfile () { if [ ! -f $1 ]; then echo "File $1 was not found.\n  Nothing was done."; exit 2; fi ;}
function fixatnname () { awk '(!(/ATOM/||/HETAMT/)){print $0;next}
                              {bnm=substr($0,1,12);anm=substr($0,13,4);fnm=substr($0,17);flc=substr(anm,1,1)}
                              {printf "%12s%4s%s\n",bnm,(flc ~ /[0-9]/)?substr(anm,2)flc:anm,fnm}' $1>t.pdb ; mv t.pdb "$1" ;}

function getcharge () { awk '/\[ atoms/{f=1;next}(f&&NF==0){exit}(f&&!/^;/){printf "%-8s %-8s %8.4f\n",$5,$2,$7}' "$2"/topol_"$1".itp > q_"$1".txt ;}
function getradius () { awk '(NR==FNR){a[$1]=$3;next}{printf "%s   %s\n",$0,($2 in a)?a[$2]:"xx"}' "$2" q_"$1".txt > qr_"$1".txt;}
function getmoltyp () { awk '/\[ moleculetype/{f=1;next}(f&&!/^;/){print $1"   "1;exit}' $1 ;}

function genpqr () { awk '(NR==FNR){a[NR]=$1;q[NR]=$3;r[NR]=$4;next}
                          (!(/ATOM/||/HETATM/)){print $0;next}
                          {c++;atnm=substr($0,13,4);gsub(" ","",atnm)}
                          {printf "%s%8s%7s\n",substr($0,1,54),q[c],r[c]}' $3 $1 > $2.pqr ;}

function get_stats () { awk -v beg=$2 'BEGIN{beg=(beg=="")?1:beg}
				(NR==1){for (i=2;i<=NF;i++){lab[i]=$i}}
                                (NR>beg){c++;for (i=2;i<=NF;i++){sum[i]+=$i;sumsq[i]+=($i)^2}}
                                END{for (i=2;i<=NF;i++){
                                      ave=sum[i]/(c);
                                      sutwo=(sum[i]^2)/(c);
                                      std=sqrt((sumsq[i]-sutwo)/(c));
                                      printf "%-12s  %10.3f +/- %10.3f\n",lab[i],ave,std}}' $1 ;}

function inter_entropy_tot () { awk -v t=$3 -v kt=2.49434 '(NR==FNR&&NR>1){a[$1]=$3+$4;next}
                                                            {b[FNR]=a[$1];avg+=b[FNR]}
                                                            END{avg=avg/FNR;
                                                                 for (x=1;x<=FNR;x++){
                                                                 delta=b[x]-avg;
                                                                 val=delta/kt;
                                                                 r+=exp(val)};
                                                                 print t,kt*log(r/FNR)}' $1 $2 ;}
