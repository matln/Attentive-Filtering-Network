#!/bin/bash 
# bash scripts for calling the following python scripts: 
# main.py: for model training feature_plot.py : for visualizing attention heatmaps 
# predict_only.py: for model forward passing 
stage=0 # parse first argument 
if [ $stage -eq 0 ]; then
    python main.py \
	      --train-scp data_slicing/train_spectrogram_cmvn_tensor.scp \
        --train-utt2label data/train_spec_cmvn/utt2spk \
        --validation-scp data_slicing/dev_spectrogram_cmvn_tensor.scp \
        --validation-utt2label data/dev_spec_cmvn/utt2spk \
        --eval-scp data_slicing/eval_spectrogram_cmvn_tensor.scp \
        --eval-utt2label data/eval_spec_cmvn/utt2spk \
        --logging-dir snapshots/attention/ --epochs 30 --log-interval 50
fi

if [ $stage -eq 1 ]; then
    CUDA_VISIBLE_DEVICES=`free-gpu` python feature_plot.py \
        --eval-scp src/data_reader/spec/new_color_map2.scp \
        --eval-utt2label src/data_reader/spec/utt2label/eval_utt2label \
        --logging-dir snapshots/predict_only/ --test-batch-size 1 \
	--plot-dir src/data_reader/plot/attention/new_colormap/shit/
fi

if [ $stage -eq 2 ]; then
    CUDA_VISIBLE_DEVICES=`free-gpu` python predict_only.py \
        --eval-scp src/data_reader/spec/train_spec_cmvn_tensor.scp \
        --eval-utt2label src/data_reader/spec/utt2label/train_utt2label \
        --logging-dir snapshots/predict_only/ --test-batch-size 4 \
	--scoring-txt snapshots/scoring/train_attention8_pred.txt \
	--label-txt snapshots/scoring/train_attention8_label.txt

    CUDA_VISIBLE_DEVICES=`free-gpu` python predict_only.py \
        --eval-scp src/data_reader/spec/dev_spec_cmvn_tensor.scp \
        --eval-utt2label src/data_reader/spec/utt2label/dev_utt2label \
        --logging-dir snapshots/predict_only/ --test-batch-size 4 \
	--scoring-txt snapshots/scoring/dev_attention8_pred.txt \
	--label-txt snapshots/scoring/dev_attention8_label.txt

    CUDA_VISIBLE_DEVICES=`free-gpu` python predict_only.py \
        --eval-scp src/data_reader/spec/eval_spec_cmvn_tensor.scp \
        --eval-utt2label src/data_reader/spec/utt2label/eval_utt2label \
        --logging-dir snapshots/predict_only/ --test-batch-size 4 \
	--scoring-txt snapshots/scoring/eval_attention8_pred.txt \
	--label-txt snapshots/scoring/eval_attention8_label.txt
fi

