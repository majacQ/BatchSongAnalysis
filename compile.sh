#!/bin/bash

#ssh login to cluster
#qlogin -l interactive=true
#cd to BatchSongAnalysis/
#./compile.sh

#to run
# ./run_batch_song_analysis.sh daq_file {genotypes} {[recording channels]} {control genotypes} LLR_threshold

#hard-coded for matlab 2013a on janelia cluster

mkdir -p batch_song_analysis

#  -R -singleCompThread \
/usr/local/matlab-2013a/bin/mcc -o batch_song_analysis \
  -W main:batch_song_analysis \
  -T link:exe \
  -d batch_song_analysis \
  -w enable:specified_file_mismatch \
  -w enable:repeated_file \
  -w enable:switch_ignored \
  -w enable:missing_lib_sentinel \
  -w enable:demo_license \
  -v BatchFlySongAnalysis.m \
  -a chronux \
  -a SplitVec

chmod g+x ./batch_song_analysis/run_batch_song_analysis.sh
ln -s ./batch_song_analysis/run_batch_song_analysis.sh
