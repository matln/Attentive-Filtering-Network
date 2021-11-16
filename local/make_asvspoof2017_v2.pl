#!/usr/bin/perl
#
# Copyright 2018  Ewald Enzinger
#           2018  David Snyder
#           2020  Jianchen Li
#
# Usage: ./make_asvspoof2017_v2.pl /data/corpus/VoxCeleb $(dirname "$PWD")/data/vox1 

# @ARGV: 传给脚本的命令行参数列表
if (@ARGV != 2) {
  print STDERR "Usage: $0 <path-to-dataset> <path-to-data-dir>\n";
  print STDERR "e.g. $0 " . '/data/corpus/ASVspoof/2017 data' . "\n";
  exit(1);
}

# my: 私有变量
($data_base, $out_dir) = @ARGV;
my $out_train_dir = "$out_dir/train";
my $out_dev_dir = "$out_dir/dev";
my $out_eval_dir = "$out_dir/eval";
my $out_train_dev_dir = "$out_dir/train_dev";

# linux 中返回0表示正确
if (system("mkdir -p $out_train_dir") != 0) {
  die "Error making directory $out_train_dir";
}
if (system("mkdir -p $out_dev_dir") != 0) {
  die "Error making directory $out_dev_dir";
}
if (system("mkdir -p $out_eval_dir") != 0) {
  die "Error making directory $out_eval_dir";
}
if (system("mkdir -p $out_train_dev_dir") != 0) {
  die "Error making directory $out_train_dev_dir";
}

open(LABEL_TRAIN, ">", "$out_train_dir/utt2spk") or die "Could not open the output file $out_train_dir/utt2spk";
open(WAV_TRAIN, ">", "$out_train_dir/wav.scp") or die "Could not open the output file $out_train_dir/wav.scp";
open(TRAIN_IN, "<", "$data_base/protocol_V2/ASVspoof2017_V2_train.trn.txt") or die "Could not open the protocol file";
open(LABEL_DEV, ">", "$out_dev_dir/utt2spk") or die "Could not open the output file $out_dev_dir/utt2spk";
open(WAV_DEV, ">", "$out_dev_dir/wav.scp") or die "Could not open the output file $out_dev_dir/wav.scp";
open(DEV_IN, "<", "$data_base/protocol_V2/ASVspoof2017_V2_dev.trl.txt") or die "Could not open the protocol file";
open(LABEL_EVAL, ">", "$out_eval_dir/utt2spk") or die "Could not open the output file $out_eval_dir/utt2spk";
open(WAV_EVAL, ">", "$out_eval_dir/wav.scp") or die "Could not open the output file $out_eval_dir/wav.scp";
open(EVAL_IN, "<", "$data_base/protocol_V2/ASVspoof2017_V2_eval.trl.txt") or die "Could not open the protocol file";
open(LABEL_TRAIN_DEV, ">", "$out_train_dev_dir/utt2spk") or die "Could not open the output file $out_train_dev_dir/utt2spk";
open(WAV_TRAIN_DEV, ">", "$out_train_dev_dir/wav.scp") or die "Could not open the output file $out_train_dev_dir/wav.scp";

while (<TRAIN_IN>) {
  chomp;    # 去掉换行符
  my ($utt, $label, $spk_id, $phr_id, $E_id, $P_id, $R_id) = split;
  my $utt_id = "$label-" . substr($utt, 0, -4);
  my $wav = "$data_base/data/ASVspoof2017_V2_train/$utt";
  print LABEL_TRAIN "$utt_id $label\n";
  print LABEL_TRAIN_DEV "$utt_id $label\n";
  print WAV_TRAIN "$utt_id $wav\n";
  print WAV_TRAIN_DEV "$utt_id $wav\n";
} 

while (<DEV_IN>) {
  chomp;    # 去掉换行符
  my ($utt, $label, $spk_id, $phr_id, $E_id, $P_id, $R_id) = split;
  my $utt_id = "$label-" . substr($utt, 0, -4);
  my $wav = "$data_base/data/ASVspoof2017_V2_dev/$utt";
  print LABEL_DEV "$utt_id $label\n";
  print LABEL_TRAIN_DEV "$utt_id $label\n";
  print WAV_DEV "$utt_id $wav\n";
  print WAV_TRAIN_DEV "$utt_id $wav\n";
} 

while (<EVAL_IN>) {
  chomp;    # 去掉换行符
  my ($utt, $label, $spk_id, $phr_id, $E_id, $P_id, $R_id) = split;
  my $utt_id = "$label-" . substr($utt, 0, -4);
  my $wav = "$data_base/data/ASVspoof2017_V2_eval/$utt";
  print LABEL_EVAL "$utt_id $label\n";
  print WAV_EVAL "$utt_id $wav\n";
} 

close(LABEL_TRAIN) or die;
close(WAV_TRAIN) or die;
close(TRAIN_IN) or die;
close(LABEL_DEV) or die;
close(WAV_DEV) or die;
close(DEV_IN) or die;
close(LABEL_EVAL) or die;
close(WAV_EVAL) or die;
close(EVAL_IN) or die;
close(LABEL_TRAIN_DEV) or die;
close(WAV_TRAIN_DEV) or die;

if (system(
  "utils/utt2spk_to_spk2utt.pl $out_train_dir/utt2spk >$out_train_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_train_dir";
}
system("env LC_COLLATE=C utils/fix_data_dir.sh $out_train_dir");
if (system("env LC_COLLATE=C utils/validate_data_dir.sh --no-text --no-feats $out_train_dir") != 0) {
  die "Error validating directory $out_train_dir";
}

if (system(
  "utils/utt2spk_to_spk2utt.pl $out_dev_dir/utt2spk >$out_dev_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_dev_dir";
}
system("env LC_COLLATE=C utils/fix_data_dir.sh $out_dev_dir");
if (system("env LC_COLLATE=C utils/validate_data_dir.sh --no-text --no-feats $out_dev_dir") != 0) {
  die "Error validating directory $out_dev_dir";
}

if (system(
  "utils/utt2spk_to_spk2utt.pl $out_eval_dir/utt2spk >$out_eval_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_eval_dir";
}
system("env LC_COLLATE=C utils/fix_data_dir.sh $out_eval_dir");
if (system("env LC_COLLATE=C utils/validate_data_dir.sh --no-text --no-feats $out_eval_dir") != 0) {
  die "Error validating directory $out_eval_dir";
}

if (system(
  "utils/utt2spk_to_spk2utt.pl $out_train_dev_dir/utt2spk >$out_train_dev_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_train_dev_dir";
}
system("env LC_COLLATE=C utils/fix_data_dir.sh $out_train_dev_dir");
if (system("env LC_COLLATE=C utils/validate_data_dir.sh --no-text --no-feats $out_train_dev_dir") != 0) {
  die "Error validating directory $out_train_dev_dir";
}
