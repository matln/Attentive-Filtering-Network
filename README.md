# Attentive Filtering Network
University of Edinbrugh-Johns Hopkins University's system for ASVspoof 2017 Version 2.0 dataset. Work is under review for ICASSP 2019.


paper on ArXiv: TO DO 

## Author 
Cheng-I Lai, Alberto Abad, Korin Richmond, Junichi Yamagishi, Najim Dehak, Simon King 

## Abstract 
An attacker may use a variety of techniques to fool an automatic speaker verification system into accepting them as a genuine user. Anti-spoofing methods meanwhile aim to make the system robust against such attacks. The ASVspoof 2017 Challenge focused specifically on replay attacks, with the intention of measuring the limits of replay attack detection as well as developing countermeasures against them. In this work, we propose our replay attacks detection system - Attentive Filtering Network, which is composed of an attention-based filtering mechanism that enhances feature representations in both the frequency and time domains, and a ResNet-based classifier. We show that the network enables us to visualize the automatically acquired feature representations that are helpful for spoofing detection. Attentive Filtering Network attains an evaluation EER of 8.99% on the ASVspoof 2017 Version 2.0 dataset. With system fusion, our best system further obtains a 30% relative improvement over the ASVspoof 2017 enhanced baseline system.

## Instruction to run 
TO DO 

## Visualization of attention heatmaps with different non-linearities
sigmoid
![sigmoid](https://github.com/jefflai108/Attentive-Filtering-Network/raw/master/github_image/sigmoid.png)

tanh
![tanh](https://github.com/jefflai108/Attentive-Filtering-Network/raw/master/github_image/tanh.png)

softmaxF (softmax on feature dimension)
![softmaxF (softmax on feature dimension)](https://github.com/jefflai108/Attentive-Filtering-Network/raw/master/github_image/softmaxF.png)

softmaxT (softmax on time dimension)
![softmaxT (softmax on time dimension)](https://github.com/jefflai108/Attentive-Filtering-Network/raw/master/github_image/softmaxT.png)

## Contact 
Cheng-I Jeff Lai: jefflai108@gmail.com

