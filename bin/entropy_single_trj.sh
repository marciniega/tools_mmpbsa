#!/usr/bin/env bash
set -e

pth2main=/shared/software/tools_mmpbsa
. "$pth2main"/lib/definitions.sh
. "$pth2main"/lib/functions.sh

enthalpy_file=$1 # mmpbsa_enthalpy.xvg
out_prefix=$2"_"
start_frame=$3
nframes=`awk 'END{print $1}' "$enthalpy_file"`

bootstrap_rep=30
if [ -z "$start_frame" ]; then
	start_frame=1
fi
echo "Starting frame: $start_frame "

nframes=$(( nframes-start_frame ));


echo "#boostrap_run  inter_entropy " > "$out_prefix"inter_entropy_bootstrap.txt
for i in `seq 1 "$bootstrap_rep"`;do
    for j in `seq 1 "$nframes"`;do echo $(( (RANDOM % nframes) + start_frame )) | bc ; done > keys
    inter_entropy_tot "$enthalpy_file" keys "$i" >> "$out_prefix"inter_entropy_bootstrap.txt
done
get_stats "$out_prefix"inter_entropy_bootstrap.txt > "$out_prefix"inter_entropy_value.txt
get_stats "$enthalpy_file" "$start_frame" > "$out_prefix"enthalpy_value.txt
rm keys 
cat "$out_prefix"enthalpy_value.txt "$out_prefix"inter_entropy_value.txt 
