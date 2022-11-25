#!/usr/bin/env bash
itpfil=$1
itpdir=$2
reffil=$3
awk '/\[ atoms/{f=1;next}(f&&NF==0){exit}(f&&!/^;/){printf "%-8s %-8s %8.4f\n",$5,$2,$7}' "$itpdir"/topol_"$itpfil".itp > chrg.txt
awk '(NR==FNR){a[$1]=$3;next}{printf "%s   %s\n",$0,($2 in a)?a[$2]:"xx"}' "$refil" chrg.txt 
