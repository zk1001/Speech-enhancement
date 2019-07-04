%% Load the neural network toolbox
clc
clear

addpath(genpath('\Source code\nnet1'))

%% Load the trained neural network
load net.mat

%% Compute the identification accuracy of the AWGN noisy data
AWGN_acc_m10
AWGN_acc_m7
AWGN_acc_m5
AWGN_acc_m3
AWGN_acc_0
AWGN_acc_3
AWGN_acc_5
AWGN_acc_10

snr_awgn = [-10 -7 -5 -3 0 3 5 10];
acc_awgn = [Accuracy_m10 Accuracy_m7 Accuracy_m5 Accuracy_m3 Accuracy_0 Accuracy_3 Accuracy_5 Accuracy_10];

%% Compute the identification accuracy of the babble noisy data
babble_acc_m13
babble_acc_m10
babble_acc_m7
babble_acc_m5
babble_acc_m3
babble_acc_0
babble_acc_3
babble_acc_10

snr_babble = [-13 -10 -7 -5 -3 0 3 10];
acc_babble = [Accuracy_b_m13 Accuracy_b_m10 Accuracy_b_m7 Accuracy_b_m5 Accuracy_b_m3 Accuracy_b_0 Accuracy_b_3 Accuracy_b_10];

%% plot the accuracy
figure
plot(snr_awgn,acc_awgn,'r-+','linewidth',2);
hold on
plot(snr_babble,acc_babble,'b-*','linewidth',2);
legend('AWGN noise','Babble noise')
xlabel('SNR(dB)')
ylabel('Accuracy (%)')

openfig performance.fig
openfig training_state.fig
openfig regression.fig