clear all;close all;clc;tic;warning off
%rng('default');rng(1);          %controle da semente aleat�ria

%% Par�metros da Simula��o

runs = 5;                     % quantidade de experimentos
modtype = 2;                    % 0:BPSK; 1:QPSK; 2: QAM
QAM_ordem = 2;                 % 2; 4; 16; 64; 256

SNR_vec = -15:3:30; %0:3:30;               % pot�ncia do ru�do AWGN

Niveis_quantizacao  = 2^16;     % quantidade de n�ves de quantiza��o
plot_const_audio = 0;           % plot figuras
play_sound = 0;                 % play audio files
save_data_out = 1;              % save vector data
salva_figura = 1;               % salva plot final
save_audio = 1;                 % 0:deleta arquivo de �udio; 1:salva

%% Par�metros Canais com M�ltiplos Caminhos
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

%% Par�metros canal MIMO/AWGN

tipo_canal = 0;                 %0:AWGN; 1:Rayleigh; 2:Rician; 3:MIMO

fs = 3.84e6;
kFactor = 3;
pathDelays = [0 2e-9];
avgPathGains = [0 -9];
dopplerEffect = vehicularA_doppler;

obejctSpeed = 4;  %in km/h
carrierFreq = 700e6;  % frequencia da onda portadora

speed_in_ms = obejctSpeed/3.6;
c = 3e8;
fd = (speed_in_ms * carrierFreq)/c;

num_tx_antennas = 4;
num_rx_antennas = 4;
fadding_mimo = 'Rayleigh';       % 'Rayleigh' or 'Rician'

%% Vari�veis de nome para arquivos

if modtype == 0
    modulation = sprintf('BPSK');
elseif modtype == 1
    modulation = sprintf('QPSK');
elseif modtype == 2
    modulation = sprintf('%0dQAM',QAM_ordem);
end

if tipo_canal == 0
    tipo_can = 'AWGN';
elseif tipo_canal == 1
    tipo_can = 'Rayleigh';    %para um futuro canal
elseif tipo_canal == 2
    tipo_can = 'Rician';
elseif tipo_canal == 3
    tipo_can = 'MIMO';
end

time_label = char(datetime('now','TimeZone','local',...
    'Format','ddMMMy_HHmmss'));

    file_Out = strcat('MOS_',tipo_can,'_',modulation,'_',...
        sprintf('%0druns_',runs),time_label,'.mat');



%% Check the .exe files at the folder

DIR = dir;
DIR_num = length(DIR);
DIR_p563 = 0;DIR_p862 = 0;DIR_Resultados = 0;
for jj = 1:DIR_num
    if strfind(DIR(jj).name, 'p563.exe') == 1
        DIR_p563 = 1;
    end
    if strfind(DIR(jj).name, 'p862.exe') == 1
        DIR_p862 = 1;
    end
    if strfind(DIR(jj).name, 'Resultados') == 1
        DIR_Resultados = 1;
    end
end

if DIR_p563 == 0 || DIR_p862 == 0
    disp('-----------------------------------------------------------')
    disp('Arquivos p862.exe e/ou p563.exe n�o encontrados na pasta')
    disp('-----------------------------------------------------------')
    clear all
    %break
end

% cria ou usa pasta Resultados
[status,message] = fileattrib;
if DIR_Resultados == 0
    mkdir Resultados
end


%% Executa rotina
audio_files_vec = {};audio_file_out_old = char('');
vec_saida = zeros(runs*numel(SNR_vec),5);
bb = 0;dd = 1;
for SNR = SNR_vec
    
    disp('-----------------------------------------------------------')
    disp('-----------------------------------------------------------')
    
    for run = 1:runs
        bb = bb + 1;
        disp('-----------------------------------------------------------')
        fprintf('Rela��o Sinal Ru�do (SNR) = %0.2f dB (run %0d of %0d)\n',...
            SNR,run,runs)
        close all
        
        %% Arquivo de �udio original
        
        info = audioinfo('m_25_en_c_se01.wav');
        str = info.Filename;
        k = strfind(str, '\');
        [y,Fs] = audioread(str(k(end)+1:end));
        t = 0:(1/Fs):info.Duration;
        t = t(1:end-1);
        
        taxa_dados = info.SampleRate*info.BitsPerSample*(7/4);
        
        %% Quantiza��o Linear
        
        quant_part = 1/(Niveis_quantizacao/2);
        partition_q = [-1+quant_part:quant_part:1-quant_part];
        codebook = [1:length(partition_q)+1];
        [index,y_quantized] = quantiz(y,partition_q,codebook);
        
        
        %% Convers�o pra bin�rio e arranjo dos bits em sequ�ncia
        
        y_quantized_binario = de2bi(y_quantized);
        y_quantized_binario_sequencial = reshape(y_quantized_binario',[],1);
        
        
        %% Hamming code (7,4)
        

            y_quantized_binario_sequencial_coded = ...
                y_quantized_binario_sequencial;

        
        %% modula��o BSPK
        
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
        
        if tipo_canal == 3 && num_tx_antennas == 4
           resto = mod(size(y_quantized_binario_sequencial_coded_pad), 3);
           while resto ~= 0
               y_quantized_binario_sequencial_coded_pad = ...
                   [y_quantized_binario_sequencial_coded_pad; 0];
               pad = pad + 1;
               resto = mod(size(y_quantized_binario_sequencial_coded_pad), 3);
           end
        end
        
        % Modulate the data
        y_quantized_binario_sequencial_mod = step(hModulator,...
            y_quantized_binario_sequencial_coded_pad);
        
        
        t_bit = (1/((1/(((1/Fs)/log2(Niveis_quantizacao))))*(7/4)));
        banda_min = 1/t_bit;
        fprintf('Banda M�nima = %.2f Hz (Periodo de Simbolo = %0.2g s)\n',...
            banda_min,t_bit)
        
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
            
            if plot_const_audio == 1
                figure;hold on
                scatter(real(sinal_recebido),imag(sinal_recebido),'b.')
                scatter(real(y_quantized_binario_sequencial_mod),...
                    imag(y_quantized_binario_sequencial_mod),'r*')
                legend('Transmitido','Recebido')
                box on;grid on;ax = gca;ax.GridLineStyle = '--';
                xlim([-1.5 1.5])
                ylim([-1.5 1.5])
                drawnow
            end
            
        
        %% Demodula��o
        
        if tipo_canal == 3
            hOSTBCComb = comm.OSTBCCombiner(...
                'NumTransmitAntennas', num_tx_antennas,...
                'NumReceiveAntennas', num_rx_antennas);
            
            chEst = squeeze(sum(pathGains, 2));
            sinal_recebido = step(hOSTBCComb, sinal_recebido, chEst);
        end
        
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
        
        hError = comm.ErrorRate;
        
        errorStats = step(hError,y_quantized_binario_sequencial_coded_pad,...
            sig_demodulado_bin);
        fprintf('Error rate = %f\nNumber of errors = %d\nExponencial Erro = %.1f\n', ...
            errorStats(1), errorStats(2),log10(errorStats(1)))
        
        sig_demodulado_bin = sig_demodulado_bin(1:end-pad);
        
        sig_demodulado_bin_decod = sig_demodulado_bin;
        
        taxa_erro_coding = sum(abs(sig_demodulado_bin_decod -...
            y_quantized_binario_sequencial))/numel(...
            y_quantized_binario_sequencial);
        fprintf('Error Rate with Coding = %f \n',taxa_erro_coding)
        
        
        %% Sequ�ncia para agrupado e convers�o bin�rio para inteiro
        
        reshape_ind = nextpow2(0.5*Niveis_quantizacao)+1;
        sig_dem_bin_seq = reshape(sig_demodulado_bin_decod',...
            [reshape_ind,length(sig_demodulado_bin_decod)/reshape_ind]);
        
        sig_dem_dec = bi2de(sig_dem_bin_seq')';
        
        %% Reverter a quantiza��o
        
        ind = find((sig_dem_dec < min(codebook))==1);
        sig_dem_dec(ind) = min(codebook);
        
        ind = find((sig_dem_dec > max(codebook))==1);
        sig_dem_dec(ind) = max(codebook);
        
        sig_desquantizado = partition_q(sig_dem_dec)';
        
        %% Plotar Sinal de �udio
        
        if plot_const_audio == 1
            figure;subplot(2,1,1)
            plot(t,y)
            xlabel('Tempo [s]','Interpreter','latex')
            ylabel('Sinal de Audio','Interpreter','latex')
            legend('Original')
            box on;grid on;ax = gca;ax.GridLineStyle = '--';
            yylim = ax.YLim;xlim([0 max(t)])
            subplot(2,1,2)
            plot(t,sig_desquantizado,'k')
            xlabel('Tempo [s]','Interpreter','latex')
            ylabel('Sinal de Audio','Interpreter','latex')
            legend('Recebido')
            box on;grid on;ax = gca;ax.GridLineStyle = '--';
            ylim(yylim);yylim = ax.YLim;xlim([0 max(t)])
            drawnow
        end
        
        %% Salva e toca o sinal de a�dio recebido
        
        if SNR < 0
            snr = sprintf('n%0d',SNR);
        else
            snr = sprintf('p%0d',SNR);
        end
        
        audio_file_out = strcat(str(k(end)+1:end-4),'_deg_',tipo_can,'_',...
            'SNR_',snr,'_',modulation,'_',time_label,'.wav');
        audiowrite(audio_file_out,sig_desquantizado,Fs)
        info = audioinfo(audio_file_out);
        [y_rec,Fs] = audioread(audio_file_out);
        if play_sound == 1
            sound(y_rec,Fs)
        end
        
        
        %% Realiza teste de MOS
        
        
        
        %P862
        command = char(strcat('p862.exe m_25_en_c_se01.wav ',...
            {'  '},audio_file_out,' +16000'));
        [~,cmdout] = system(command);
        pos = strfind(cmdout, 'PESQ_MOS');
        MOS_valor1 = str2num(cmdout(pos+10:pos+15));
        fprintf('PESQ_MOS = %0.3f \n',MOS_valor1)
        
        
        %P563
        command2 = char(strcat('p563.exe ',...
            {'  '},audio_file_out));
        [~,cmdout2] = system(command2);
        pos2 = strfind(cmdout2, audio_file_out);
        pos3 = size(audio_file_out,2)+ pos2;
        p563out = cmdout2(pos3+1:pos3+3);
        tf = strcmp(p563out,'nan');
        
        if tf == 1
            MOS_valor2 = 1;
        else
            MOS_valor2 = str2num(cmdout2(pos3+1:pos3+6));
        end
        fprintf('P563_MOS = %0.3f \n',MOS_valor2)
        
        if save_audio == 0
            delete(strcat(audio_file_out))
        else
            if strcmp(audio_file_out_old,audio_file_out) == 0
                audio_files_vec(dd,:) = {strcat(audio_file_out)};
                dd = dd + 1;
            end
        end
        audio_file_out_old = audio_file_out;
        
        %% Salva os dados em um vetor
        
        vec_saida(bb,:) = [SNR MOS_valor1 MOS_valor2...
            errorStats(1) taxa_erro_coding];
        
        if save_data_out == 1
            save(file_Out,'vec_saida')
        end
        
        
    end
end

%% M�dia dos dados

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
    fprintf('SNR: %0.6f - P.862: %0.6f    P.563: %0.6f    BER: %0.6f\n', mean_vec(i,1), mean_vec(i,2), mean_vec(i,3), mean_vec(i,4));
end
    

%% Plot do MOS e BER m�dios

figure;subplot(2,1,1);hold on
plot(mean_vec(:,1),mean_vec(:,2),'rx-')
plot(mean_vec(:,1),mean_vec(:,3),'bd-')
box on;grid on;ax = gca;ax.GridLineStyle = '--';
ax.YTick = 0:0.5:4.5;ax.XTick = mean_vec(:,1);
xlabel('SNR [dB]','Interpreter','latex')
ylabel('$$\overline{\rm MOS}$$','Interpreter','latex')
%legend(modulation,'Location','NW')
legend('P.862','P.563','Location','SE')
ylim([0 4.5]);
%title(strcat(modulation,sprintf(' (%0d runs)',runs)))
title(strcat(modulation))


if salva_figura == 1
    export_fig(strcat(message.Name,'\Resultados\','MOS_',tipo_can,'_',...
        modulation,'_',sprintf('%0druns_',runs),time_label), '-pdf');
end

%% Move os arquivos de audio

if save_audio == 1
    [wav_files_num,~] = size(audio_files_vec);
    cd((strcat(message.Name,'\Resultados')))
    
    old_string = 0;
    for gg = 1:wav_files_num
        if strcmp(audio_files_vec{gg,:},old_string) == 0
            movefile(char(strcat('../',audio_files_vec{gg,:})))
        end
        old_string = strcat(audio_files_vec{gg,:});
    end
end

if save_data_out == 1
    save(file_Out)
    cd((strcat(message.Name,'\Resultados')))
    movefile(char(strcat('../',file_Out)))
    cd('..')
end

%%
disp('-----------------------------------------------------------')
if save_data_out == 1
    disp(char(strcat('Resultados salvos em:',{' '},message.Name,'\Resultados')))
    disp(char(strcat('-->',{' '},file_Out)))
    disp(char(strcat('-->',{' '},'MOS_',tipo_can,'_',modulation,'_',sprintf('%0druns_',runs),time_label,'.pdf')))
end

toc
disp('FIM')

