clear all;close all;clc;tic;warning off

%% Parâmetros da Simulação
runs = 5;

SNR_vec = -15:3:30;               % potência do ruído AWGN

%% Parâmetros Canais com Múltiplos Caminhos
indoorA_delay = [0 50 110 170 290 310]*1e-9;
indoorA_power = [0 -3.0 -10.0 -18.0 -26.0 -32.0];
indoorA_doppler = doppler('Flat');

indoorB_delay = [0 100 200 300 500 700]*1e-9;
indoorB_power = [0 -3.6 -7.2 -10.8 -18.0 -25.2];
indoorB_doppler = doppler('Flat');

pedestrianA_delay = [0 110 190 410]*1e-9;
pedestrianA_power = [0 -9.7 -19.2 -22.8];
pedestrianA_doppler = doppler('Jakes');

pedestrianB_delay = [0 200 800 1200 2300 3700]*1e-9;
pedestrianB_power = [0 -0.9 -4.9 -8.0 -7.8 -23.9];
pedestrianB_doppler = doppler('Jakes');

vehicularA_delay = [0 310 710 1090 1730 2510]*1e-9;
vehicularA_power = [0 -1.0 -9.0 -10.0 -15.0 -20.0];
vehicularA_doppler = doppler('Jakes');

vehicularB_delay = [0 300 8900 12900 17100 20000]*1e-9;
vehicularB_power = [-2.5 0 -12.8 -10.0 -25.2 -16.0];
vehicularB_doppler = doppler('Jakes');

%% Parâmetros canal MIMO/AWGN

modtype = 0;                    % 0:BPSK; 1:QPSK; 2: QAM
QAM_ordem = 256;                 % 2; 4; 16; 64; 256

tipo_canal = 3;                 %0:AWGN; 1:Rayleigh; 2:Rician; 3:MIMO

remove_delay = 0;

fs = 3.84e6;
kFactor = 7;
pathDelays = vehicularA_delay*0;
avgPathGains = vehicularA_power;
dopplerEffect = vehicularA_doppler;

obejctSpeed = 120;  %in km/h
carrierFreq = 700e6;  % frequencia da onda portadora

speed_in_ms = obejctSpeed/3.6;
c = 3e8;
fd = (speed_in_ms * carrierFreq)/c;

num_tx_antennas = 2;
num_rx_antennas = 1;
fadding_mimo = 'Rayleigh';       % 'Rayleigh' or 'Rician'

%% Executa rotina
vec_saida = zeros(runs*numel(SNR_vec), 2);
bb = 0;dd = 1;

M = 2;
tx = randi([0 M-1],60000,1); % Generate a random bit stream

scatterPlot = comm.ConstellationDiagram;

for SNR = SNR_vec
    
    disp('-----------------------------------------------------------')
    disp('-----------------------------------------------------------')
    
    for run = 1:runs
        bb = bb + 1;
        disp('-----------------------------------------------------------')
        fprintf('Relação Sinal Ruído (SNR) = %0.2f dB (run %0d of %0d)\n',...
            SNR,run,runs)
        close all
        
       %% modulação BSPK
        
       y_quantized_binario_sequencial_coded = tx;
       
        % Create a modulator System object
        if modtype == 0
            hModulator = comm.BPSKModulator;
            pad = 0;
            y_quantized_binario_sequencial_coded_pad = ...
                y_quantized_binario_sequencial_coded;
            bits_simbolo = 1;
            
        elseif modtype == 1
            hModulator = comm.QPSKModulator('BitInput',true);
            bits_simbolo = 2;
            pad = (bits_simbolo*round(numel(...
                y_quantized_binario_sequencial_coded)/bits_simbolo)...
                - numel(y_quantized_binario_sequencial_coded));
            y_quantized_binario_sequencial_coded_pad = ...
                [y_quantized_binario_sequencial_coded;...
                zeros(pad,1)]; % acrescenta bits extras
            
        elseif modtype == 2
            bits_simbolo = log2(QAM_ordem);
            MinDist_QAM = sqrt(1/((QAM_ordem-1)/6));
            hModulator = comm.RectangularQAMModulator('ModulationOrder',...
                QAM_ordem,'BitInput',true,'MinimumDistance',MinDist_QAM);
            pad = (bits_simbolo*round(numel(...
                y_quantized_binario_sequencial_coded)/bits_simbolo)...
                - numel(y_quantized_binario_sequencial_coded));
            y_quantized_binario_sequencial_coded_pad = ...
                [y_quantized_binario_sequencial_coded;...
                zeros(pad,1)]; % acrescenta bits extras
        end
        
        % Modulate the data
        y_quantized_binario_sequencial_mod = step(hModulator,...
            y_quantized_binario_sequencial_coded_pad);
        
        %% Canal AWGN 
        
        if tipo_canal == 0 % Canal AWGN
            hAWGN = comm.AWGNChannel('NoiseMethod',...
                'Signal to noise ratio (SNR)','SNR',SNR);
            sinal_recebido = step(hAWGN,y_quantized_binario_sequencial_mod);
        elseif tipo_canal == 1
            rayChan = comm.RayleighChannel('SampleRate', fs, ...
                'MaximumDopplerShift', fd, ...
                'PathDelays', pathDelays, ...
                'AveragePathGains', avgPathGains, ...
                'DopplerSpectrum', dopplerEffect);
            y_rayleigh = rayChan(y_quantized_binario_sequencial_mod);
            
            hAWGN = comm.AWGNChannel('NoiseMethod',...
                'Signal to noise ratio (SNR)','SNR',SNR);
            sinal_recebido = step(hAWGN, y_rayleigh);
        elseif tipo_canal == 2
            ricianChan = comm.RicianChannel('SampleRate', fs, ...
                'MaximumDopplerShift', fd, ...
                'PathDelays', pathDelays, ...
                'AveragePathGains', avgPathGains, ...
                'KFactor', kFactor, ...
                'DopplerSpectrum', dopplerEffect);
            y_rician = ricianChan(y_quantized_binario_sequencial_mod);
            
            hAWGN = comm.AWGNChannel('NoiseMethod',...
                'Signal to noise ratio (SNR)','SNR',SNR);
            sinal_recebido = step(hAWGN, y_rician);
        elseif tipo_canal == 3
            hOSTBCEnc = comm.OSTBCEncoder('NumTransmitAntennas', num_tx_antennas, 'SymbolRate', 3/4);
            encData = step(hOSTBCEnc, y_quantized_binario_sequencial_mod);
            
            mimochan = comm.MIMOChannel('SampleRate', fs, ...
                'MaximumDopplerShift', fd, ...
                'PathDelays', pathDelays, ...
                'AveragePathGains', avgPathGains, ...
                'FadingDistribution', 'Rayleigh', ...
                'KFactor', kFactor, ...
                'DopplerSpectrum', dopplerEffect, ...
                'NumTransmitAntennas', num_tx_antennas, ...
                'NumReceiveAntennas', num_rx_antennas, ...
                'SpatialCorrelationSpecification', 'None', ...
                'PathGainsOutputPort', true);
            
            [y_mimo, pathGains] = mimochan(encData);
            
            hAWGN = comm.AWGNChannel('NoiseMethod',...
                'Signal to noise ratio (SNR)','SNR',SNR);
            sinal_recebido = step(hAWGN, y_mimo);
        end
        
        %% Demodulação
        if tipo_canal == 3
            hOSTBCComb = comm.OSTBCCombiner(...
                'NumTransmitAntennas', num_tx_antennas,...
                'NumReceiveAntennas', num_rx_antennas);
            
            chEst = squeeze(sum(pathGains, 2));
            sinal_recebido = step(hOSTBCComb, sinal_recebido, chEst);
        end
         
        update(scatterPlot, sinal_recebido);
        
        if modtype == 0
            hDemod = comm.BPSKDemodulator;
        elseif modtype == 1
            hDemod = comm.QPSKDemodulator('PhaseOffset',pi/4,'BitOutput',true);
        elseif modtype == 2
            hDemod = comm.RectangularQAMDemodulator('ModulationOrder',...
                QAM_ordem,'BitOutput',true,'MinimumDistance',MinDist_QAM);
        end
        
        % Demodulate
        sig_demodulado_bin = step(hDemod,sinal_recebido);
        
        % Collect error stats
        if remove_delay == 1
           if tipo_canal == 1
               chInfo = info(rayChan);
           elseif tipo_canal == 2
               chInfo = info(ricianChan);
           elseif tipo_canal == 3
               chInfo = info(mimochan);
           end
           delay = chInfo.ChannelFilterDelay;
           
           hError = comm.ErrorRate('ReceiveDelay', delay);
        else
           hError = comm.ErrorRate();
        end
        
        errorStats = step(hError,y_quantized_binario_sequencial_coded,...
            sig_demodulado_bin);
        fprintf('Error rate = %f\nNumber of errors = %d\nExponencial Erro = %.1f\n', ...
            errorStats(1), errorStats(2),log10(errorStats(1)))
        
        %% Salva os dados em um vetor
        
        vec_saida(bb,:) = [SNR errorStats(1)];
        
    end
end

%% Média dos dados

ind_j = length(SNR_vec);
[~,cc] = size(vec_saida);
mean_vec = zeros(ind_j,cc);
for jj = 0:ind_j-1
    mean_vec(jj+1,:) = mean(vec_saida([runs*jj+1:(runs*jj)+runs],:),1);
end

%% Printa os valores de media
disp('----------------------------------------------------')
disp('----             MEDIA DOS VALORES              ----')
for i = 1:ind_j
    fprintf('SNR: %0.6f - BER: %0.6f\n', mean_vec(i,1), mean_vec(i,2));
end

toc
disp('FIM')
