#!/bin/bash

# Copyright 2012-2016  Johns Hopkins University (Author: Daniel Povey)
# Apache 2.0
# To be run from .. (one directory up from here)
# see ../run.sh for example

# Begin configuration section.
nj=4
cmd=run.pl
mfcc_config=conf/mfcc.conf
compress=true
write_utt2num_frames=true  # If true writes utt2num_frames.
write_utt2dur=true
# End configuration section.

echo "$0 $@"  # Print the command line for logging.

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
  cat >&2 <<EOF
Usage: $0 [options] <data-dir> [<log-dir> [<mfcc-dir>] ]
 e.g.: $0 data/train
Note: <log-dir> defaults to <data-dir>/log, and
      <mfcc-dir> defaults to <data-dir>/data.
Options:
  --mfcc-config <config-file>          # config passed to compute-mfcc-feats.
  --nj <nj>                            # number of parallel jobs.
  --cmd <run.pl|queue.pl <queue opts>> # how to run jobs.
  --write-utt2num-frames <true|false>  # If true, write utt2num_frames file.
  --write-utt2dur <true|false>         # If true, write utt2dur file.
EOF
   exit 1;
fi

data=$1
if [ $# -ge 2 ]; then
  logdir=$2
else
  logdir=$data/log
fi
if [ $# -ge 3 ]; then
  mfccdir=$3
else
  mfccdir=$data/data
fi

# make $mfccdir an absolute pathname.
# 如果在$dir左边匹配没有匹配到/
# ${PWD}: /home/lijianchen/kaldi/egs/voxceleb/v2/steps
mfccdir=`perl -e '($dir,$pwd)= @ARGV; if($dir!~m:^/:) { $dir = "$pwd/$dir"; } print $dir; ' $mfccdir ${PWD}`

# use "name" as part of name of the archive.
name=`basename $data`

mkdir -p $mfccdir || exit 1;
mkdir -p $logdir || exit 1;

if [ -f $data/feats.scp ]; then
  mkdir -p $data/.backup
  echo "$0: moving $data/feats.scp to $data/.backup"
  mv $data/feats.scp $data/.backup
fi

scp=$data/wav.scp

required="$scp $mfcc_config"

# 判断所需要的wav.scp和mfcc-config文件是否存在
for f in $required; do
  if [ ! -f $f ]; then
    echo "$0: no such file $f"
    exit 1;
  fi
done

# 因为数据准备阶段的错误会影响后续脚本的运行，所以我们需要下面的脚本验证
# 数据目录的文件格式是否正确
utils/validate_data_dir.sh --no-text --no-feats $data || exit 1;

if [ -f $data/spk2warp ]; then
  echo "$0 [info]: using VTLN warp factors from $data/spk2warp"
  vtln_opts="--vtln-map=ark:$data/spk2warp --utt2spk=ark:$data/utt2spk"
elif [ -f $data/utt2warp ]; then
  echo "$0 [info]: using VTLN warp factors from $data/utt2warp"
  vtln_opts="--vtln-map=ark:$data/utt2warp"
else
  vtln_opts=""
fi

# TODO
for n in $(seq $nj); do
  # the next command does nothing unless $mfccdir/storage/ exists, see
  # utils/create_data_link.pl for more info.
  utils/create_data_link.pl $mfccdir/raw_mfcc_$name.$n.ark
done


if $write_utt2num_frames; then
  # text格式的ark文件，ark有两种格式：text、binary
  write_num_frames_opt="--write-num-frames=ark,t:$logdir/utt2num_frames.JOB"
else
  write_num_frames_opt=
fi

if $write_utt2dur; then
  write_utt2dur_opt="--write-utt2dur=ark,t:$logdir/utt2dur.JOB"
else
  write_utt2dur_opt=
fi

if [ -f $data/segments ]; then
  echo "$0 [info]: segments file exists: using that."

  split_segments=
  for n in $(seq $nj); do
    split_segments="$split_segments $logdir/segments.$n"
  done

  utils/split_scp.pl $data/segments $split_segments || exit 1;
  rm $logdir/.error 2>/dev/null

  $cmd JOB=1:$nj $logdir/make_mfcc_${name}.JOB.log \
    extract-segments scp,p:$scp $logdir/segments.JOB ark:- \| \
    compute-mfcc-feats $vtln_opts $write_utt2dur_opt --verbose=2 \
      --config=$mfcc_config ark:- ark:- \| \
    copy-feats --compress=$compress $write_num_frames_opt ark:- \
      ark,scp:$mfccdir/raw_mfcc_$name.JOB.ark,$mfccdir/raw_mfcc_$name.JOB.scp \
     || exit 1;

else
  echo "$0: [info]: no segments file exists: assuming wav.scp indexed by utterance."
  split_scps=
  for n in $(seq $nj); do
    split_scps="$split_scps $logdir/wav_${name}.$n.scp"
  done

  # 把$scp的所有行平均分成$nj份，最后剩下的几行单独一个个分配在前几个$n.scp
  utils/split_scp.pl $scp $split_scps || exit 1;


  # add ,p to the input rspecifier so that we can just skip over
  # utterances that have bad wave data.

  # path:$KALDI_ROOT/src/featbin/compute-mfcc-feats, 
  # compute-mfcc-feats 的wspecifier是输出到stdout，格式为ark，并通过管道传给copy-feats。rspecifier中
  # 的p意味着当我们需要的文件不存在时，程序不会崩溃
  # run.pl中，文件名中的"JOB"会被替换为$jobid 
  $cmd JOB=1:$nj $logdir/make_mfcc_${name}.JOB.log \
    compute-mfcc-feats $vtln_opts $write_utt2dur_opt --verbose=2 \
      --config=$mfcc_config scp,p:$logdir/wav_${name}.JOB.scp ark:- \| \
    copy-feats $write_num_frames_opt --compress=$compress ark:- \
      ark,scp:$mfccdir/raw_mfcc_$name.JOB.ark,$mfccdir/raw_mfcc_$name.JOB.scp \
      || exit 1;
fi


if [ -f $logdir/.error.$name ]; then
  echo "$0: Error producing MFCC features for $name:"
  tail $logdir/make_mfcc_${name}.1.log
  exit 1;
fi

# concatenate the .scp files together.
for n in $(seq $nj); do
  cat $mfccdir/raw_mfcc_$name.$n.scp || exit 1
done > $data/feats.scp || exit 1

if $write_utt2num_frames; then
  for n in $(seq $nj); do
    cat $logdir/utt2num_frames.$n || exit 1
  done > $data/utt2num_frames || exit 1
fi

if $write_utt2dur; then
  for n in $(seq $nj); do
    cat $logdir/utt2dur.$n || exit 1
  done > $data/utt2dur || exit 1
fi

# Store frame_shift and mfcc_config along with features.
frame_shift=$(perl -ne 'if (/^--frame-shift=(\d+)/) {
                          printf "%.3f", 0.001 * $1; exit; }' $mfcc_config)
echo ${frame_shift:-'0.01'} > $data/frame_shift
mkdir -p $data/conf && cp $mfcc_config $data/conf/mfcc.conf || exit 1

rm $logdir/wav_${name}.*.scp  $logdir/segments.* \
   $logdir/utt2num_frames.* $logdir/utt2dur.* 2>/dev/null

nf=$(wc -l < $data/feats.scp)
nu=$(wc -l < $data/utt2spk)
if [ $nf -ne $nu ]; then
  echo "$0: It seems not all of the feature files were successfully procesed" \
       "($nf != $nu); consider using utils/fix_data_dir.sh $data"
fi

if (( nf < nu - nu/20 )); then
  echo "$0: Less than 95% the features were successfully generated."\
       "Probably a serious error."
  exit 1
fi


echo "$0: Succeeded creating MFCC features for $name"
