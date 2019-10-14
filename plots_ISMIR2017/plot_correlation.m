fig = generateFigure(8,6);
hold on;
plot(lags1*1024/22050,prod_corr1); xlabel('Time (s)'); ylabel('Correlation');
plot(lags2*1024/22050,prod_corr2); xlabel('Time (s)'); ylabel('Correlation'); title('Geometric Mean of Correlations for all Activations');
axis([0 65 0 1])
legend('Sample Present','Sample Absent');
set(fig, 'PaperUnits','centimeters','PaperSize', [8 6], 'PaperPositionMode', 'manual','Paperposition',[0 0 8 6]);
print(fig,'plots_ISMIR2017/correlation.pdf','-dpdf')