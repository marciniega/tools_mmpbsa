#!/usr/bin/env bash
pth2src=`pwd | awk '{print "pth2main="$0}'`

awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' bin/mmpbsa_single_trj.sh > tmpsingle.tmp
mv tmpsingle.tmp bin/mmpbsa_single_trj.sh
chmod 755 bin/mmpbsa_single_trj.sh
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' bin/mmpbsa_triple_trj.sh > tmptriple.tmp
mv tmptriple.tmp bin/mmpbsa_triple_trj.sh 
chmod 755 bin/mmpbsa_triple_trj.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/run_pool_mmpbsa.sh > tmprpm.tmp
mv tmprpm.tmp src/run_pool_mmpbsa.sh 
chmod 755 src/run_pool_mmpbsa.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/get_y_files.sh > tmpgyf.tmp
mv tmpgyf.tmp src/get_y_files.sh 
chmod 755 src/get_y_files.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/our_apolar_special.sh > tmpapol.tmp
mv tmpapol.tmp src/our_apolar_special.sh 
chmod 755 src/our_apolar_special.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/our_mm_by_res.sh > tmpmmr.tmp
mv tmpmmr.tmp src/our_mm_by_res.sh 
chmod 755 src/our_mm_by_res.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' bin/entropy_single_trj.sh > tmpest.tmp
mv tmpest.tmp bin/entropy_single_trj.sh 
chmod 755 bin/entropy_single_trj.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/mmpbsa_main.sh > tmpmain.tmp
mv tmpmain.tmp src/mmpbsa_main.sh 
chmod 755 src/mmpbsa_main.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/mmpbsa_by_frame.sh > tmpmf.tmp
mv tmpmf.tmp src/mmpbsa_by_frame.sh 
chmod 755 src/mmpbsa_by_frame.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/our_polar_special.sh > tmppol.tmp
mv tmppol.tmp src/our_polar_special.sh
chmod 755 src/our_polar_special.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/our_mm_special.sh > tmpmms.tmp
mv tmpmms.tmp src/our_mm_special.sh 
chmod 755 src/our_mm_special.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' src/our_apolar_by_res.sh > tmpapor.tmp
mv tmpapor.tmp src/our_apolar_by_res.sh 
chmod 755 src/our_apolar_by_res.sh 
awk -v t="$pth2src" '/^pth2main/{print t;next}!(/^pth2main/)' lib/definitions.sh > tmpdef.tmp
mv tmpdef.tmp lib/definitions.sh 
chmod 755 lib/definitions.sh 
