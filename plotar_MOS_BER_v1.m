
clear all;close all;clc

%% Carrega os arquivos desejados

file_input_vec = {...
    'MOS_AWGN_BPSK_10runs_08Sep2017_125547.mat';
    'MOS_AWGN_BPSK_Hamming74_10runs_08Sep2017_103834.mat';
    'MOS_MIMO_BPSK_Hamming74_10runs_08Sep2017_092214.mat';
    'MOS_AWGN_QPSK_10runs_08Sep2017_131833.mat';
    'MOS_AWGN_QPSK_Hamming74_10runs_08Sep2017_110102.mat';
    'MOS_MIMO_QPSK_Hamming74_10runs_08Sep2017_094817.mat';
    'MOS_AWGN_16QAM_10runs_08Sep2017_134026.mat';
    'MOS_AWGN_16QAM_Hamming74_10runs_08Sep2017_112933.mat';
    'MOS_MIMO_16QAM_Hamming74_10runs_08Sep2017_101336.mat';
    'MOS_AWGN_64QAM_10runs_08Sep2017_140225.mat';
    'MOS_AWGN_64QAM_Hamming74_10runs_08Sep2017_121030.mat';
    'MOS_MIMO_64QAM_Hamming74_10runs_08Sep2017_085720.mat'};

file_input_vec = {...
'MOS_AWGN_QPSK_100runs_12Sep2017_090527.mat';
'MOS_AWGN_QPSK_Hamming74_100runs_09Sep2017_195003.mat';
'MOS_MIMO_QPSK_100runs_11Sep2017_085122.mat';
'MOS_MIMO_QPSK_Hamming74_100runs_12Sep2017_014828.mat'};



size_vec = numel(file_input_vec);

%% Cria o vetor médio e plot o MOS médio

% Generate 5 hue-saturation-value color map for your data
colorVec = parula(size_vec);
markers ='sssooo***ddd'; %{'+','o','*','.','x','s','d','^','v','>','<','p','h'}
markers ='so*d'; %{'+','o','*','.','x','s','d','^','v','>','<','p','h'}
linestyle = ['-'];

figure;hold all
for uu = 1:size_vec
    load(file_input_vec{uu})
    mean_vec = [];
    ind_j = length(SNR_vec);runs = length(vec_saida)/length(SNR_vec);
    for jj = 0:ind_j-1
        mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:),1)];
    end
    evalc(sprintf('mean_vec_%d = mean_vec', uu));
    
    plot(mean_vec(:,1),mean_vec(:,2),...
        [linestyle markers(uu) colorVec(uu,:)],'LineWidth',1.1)
    
    %strfind(file_input_vec{uu},'QPSK')
    %strfind(file_input_vec{uu},'BPSK')
    
end
box on;grid on;ax = gca;ax.GridLineStyle = '--';
ax.YTick = 0:0.5:4.5;
ax.XTick = mean_vec(:,1);
xlabel('SNR [dB]','Interpreter','latex')
ylabel('$$\overline{\rm MOS}$$','Interpreter','latex')
ylim([0 4.5]);
legend('BPSK','BPSK (c)','BPSK (mc)','QPSK','QPSK(c)','QPSK (mc)',...
    '16QAM','16QAM (c)','16QAM (mc)','64QAM','64QAM (c)','64QAM (mc)',...
    'Location','SE')
legend('QPSK','QPSK (Coding)','QPSK (MIMO)','QPSK (MIMO+Coding)','Location','SE')
export_fig QPSK_MOS_100runs.pdf -transparent

%% Plot o P.562 médio

figure;hold all
for uu = 1:size_vec
    load(file_input_vec{uu})
    mean_vec = [];
    ind_j = length(SNR_vec);runs = length(vec_saida)/length(SNR_vec);
    for jj = 0:ind_j-1
        mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:),1)];
    end
    evalc(sprintf('mean_vec_%d = mean_vec', uu));
    plot(mean_vec(:,1),mean_vec(:,3),...
        [linestyle markers(uu) colorVec(uu,:)],'LineWidth',1.1)
end
box on;grid on;ax = gca;ax.GridLineStyle = '--';
ax.YTick = 0:0.5:4.5;
ax.XTick = mean_vec(:,1);
xlabel('SNR [dB]','Interpreter','latex')
ylabel('$$\overline{\rm P.562}$$','Interpreter','latex')
ylim([0 3]);
legend('BPSK','BPSK (c)','BPSK (mc)','QPSK','QPSK(c)','QPSK (mc)',...
    '16QAM','16QAM (c)','16QAM (mc)','64QAM','64QAM (c)','64QAM (mc)',...
    'Location','SE')
legend('QPSK','QPSK(c)','QPSK (m)','QPSK (mc)','Location','SE')
export_fig QPSK_P562_100runs.pdf -transparent

%%  Plot o MOS médio
figure;
for uu = 1:size_vec
    load(file_input_vec{uu})
    mean_vec = [];
    ind_j = length(SNR_vec);runs = length(vec_saida)/length(SNR_vec);
    for jj = 0:ind_j-1
        mean_vec = [mean_vec; mean(vec_saida([runs*jj+1:(runs*jj)+runs],:),1)];
    end
    evalc(sprintf('mean_vec_%d = mean_vec', uu));
    semilogy(mean_vec(:,1),mean_vec(:,5),...
        [linestyle markers(uu) colorVec(uu,:)],'LineWidth',1.1)
    hold all
end
box on;grid on;ax = gca;ax.GridLineStyle = '--';
ax.XTick = mean_vec(:,1);
xlim = ([min(mean_vec(:,1)) max(mean_vec(:,1))]);
ylim([0.00000001 1])
ax.YTick = [0.00000001 0.0000001 0.000001 0.00001 0.0001 0.001 0.01 0.1 1];
xlabel('SNR [dB]','Interpreter','latex')
ylabel('$$\overline{\rm BER}$$','Interpreter','latex')
legend('BPSK','BPSK (c)','BPSK (mc)','QPSK','QPSK(c)','QPSK (mc)',...
    '16QAM','16QAM (c)','16QAM (mc)','64QAM','64QAM (c)','64QAM (mc)',...
    'Location','SE')
legend('QPSK','QPSK(c)','QPSK (m)','QPSK (mc)','Location','NE')
export_fig QPSK_BER_100runs.pdf -transparent
