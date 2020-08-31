
clear all;close all;clc

load('quantizacao_vs_MOS')


figure;subplot(2,1,1)
plot(log2(vec_quantiz(:,1)),vec_quantiz(:,2),'ks-','LineWidth',1)
box on;grid on;ax = gca;ax.GridLineStyle = '--';
ax.XTickLabel =[];
ylabel('Erro max.','Interpreter','latex')

subplot(2,1,2)
plot(log2(vec_quantiz(:,1)),vec_quantiz(:,3),'ks-','LineWidth',1)
box on;grid on;ax = gca;ax.GridLineStyle = '--';
xlabel('bits (quantização)','Interpreter','latex')
ylabel('MOS','Interpreter','latex')
ax.YTick = 0:0.5:4.5;ylim([0 4.5]);

export_fig('bits_vs_MOS', '-pdf');

