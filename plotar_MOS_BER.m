
clear all;close all;clc

SNR_vec = 0:3:30;             %potência do ruído AWGN
runs = 500;                     % quantidade de experimentos

mean_vec = [];
load('MOS_BPSK_01-Sep-2017_0708710.mat')
%load('MOS_BPSK_100runs_Hamming0_04-Sep-2017_0753431.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
figure;
%subplot(2,1,1);
hold on
plot(mean_vec(:,1),mean_vec(:,2),'rx-')

mean_vec = [];
load('MOS_AWGN_BPSK_Hamming74_500runs_07Sep2017_083252.mat')
%load('MOS_BPSK_100runs_Hamming0_04-Sep-2017_0753431.mat')
ind_j = length([0:3:6]);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
plot(mean_vec(:,1),mean_vec(:,2),'rx--')


mean_vec = [];
load('MOS_QPSK_31-Aug-2017_0759515.mat')
%load('MOS_BPSK_100runs_Hamming1_04-Sep-2017_0711367.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
plot(mean_vec(:,1),mean_vec(:,2),'bo-')


mean_vec = [];
load('MOS_QPSK_500runs_Hamming1_07-Sep-2017_0136991.mat')
%load('MOS_BPSK_100runs_Hamming1_04-Sep-2017_0711367.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
plot(mean_vec(:,1),mean_vec(:,2),'bo--')

mean_vec = [];
load('MOS_16QAM_31-Aug-2017_0113182.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
plot(mean_vec(:,1),mean_vec(:,2),'md-')

mean_vec = [];
load('MOS_16QAM_500runs_Hamming1_07-Sep-2017_0249831.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
plot(mean_vec(:,1),mean_vec(:,2),'md--')


load('MOS_64QAM_30-Aug-2017_0717780.mat')
mean_vec = [];
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
plot(mean_vec(:,1),mean_vec(:,2),'ks-')

load('MOS_64QAM_500runs_Hamming1_07-Sep-2017_0322339.mat')
mean_vec = [];
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
plot(mean_vec(:,1),mean_vec(:,2),'ks--')


box on;grid on;ax = gca;ax.GridLineStyle = '--';
%ax.YTick = 0:0.5:4.5;
ax.XTick = mean_vec(:,1);
xlabel('SNR [dB]','Interpreter','latex')
ylabel('$$\overline{\rm MOS}$$','Interpreter','latex')
legend('BPSK','BPSK (c)','QPSK','QPSK (c)','16QAM','16QAM (c)','64QAM','64QAM (c)','Location','NW')
%legend('BPSK [no coding]','BPSK [Hamming(7,4)]','Location','NW','Orientation','vertical')
ylim([0 5]);

export_fig MOS_AWGN_500runs_Coding.pdf -transparent

%%

mean_vec = [];
load('MOS_BPSK_01-Sep-2017_0708710.mat')
%load('MOS_BPSK_100runs_Hamming0_04-Sep-2017_0753431.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
%subplot(2,1,2);
figure
semilogy(mean_vec(:,1),mean_vec(:,3),'rx-')
hold all

mean_vec = [];
load('MOS_AWGN_BPSK_Hamming74_500runs_07Sep2017_083252.mat')
%load('MOS_BPSK_100runs_Hamming0_04-Sep-2017_0753431.mat')
ind_j = length([0:3:6]);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
semilogy(mean_vec(:,1),mean_vec(:,5),'rx--')


mean_vec = [];
load('MOS_QPSK_31-Aug-2017_0759515.mat')
%load('MOS_BPSK_100runs_Hamming1_04-Sep-2017_0711367.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
semilogy(mean_vec(:,1),mean_vec(:,3),'bo-')

mean_vec = [];
load('MOS_QPSK_500runs_Hamming1_07-Sep-2017_0136991.mat')
%load('MOS_BPSK_100runs_Hamming1_04-Sep-2017_0711367.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
semilogy(mean_vec(:,1),mean_vec(:,5),'bo--')


mean_vec = [];
load('MOS_16QAM_31-Aug-2017_0113182.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
semilogy(mean_vec(:,1),mean_vec(:,3),'md-')


mean_vec = [];
load('MOS_16QAM_500runs_Hamming1_07-Sep-2017_0249831.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
semilogy(mean_vec(:,1),mean_vec(:,5),'md--')


mean_vec = [];
load('MOS_64QAM_30-Aug-2017_0717780.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
semilogy(mean_vec(:,1),mean_vec(:,3),'ks-')

mean_vec = [];
load('MOS_64QAM_500runs_Hamming1_07-Sep-2017_0322339.mat')
ind_j = length(SNR_vec);
for jj = 0:ind_j-1
    mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:))];
end
semilogy(mean_vec(:,1),mean_vec(:,5),'ks--')

box on;grid on;ax = gca;ax.GridLineStyle = '--';
ax.XTick = mean_vec(:,1);ylim([0.00000001 1])
ax.YTick = [0.00000001 0.0000001 0.000001 0.00001 0.0001 0.001 0.01 0.1 1];
xlabel('SNR [dB]','Interpreter','latex')
ylabel('$$\overline{\rm BER}$$','Interpreter','latex')
%legend('BPSK','QPSK','16QAM','64QAM','Location','SW')
legend('BPSK','BPSK (c)','QPSK','QPSK (c)','16QAM','16QAM (c)','64QAM','64QAM (c)','Location','SW')
%legend('BPSK [no coding]','BPSK [Hamming(7,4)]','Location','SW','Orientation','vertical')

export_fig BER_AWGN_500runs_Coding.pdf -transparent
