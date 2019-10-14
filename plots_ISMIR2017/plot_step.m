fig = generateFigure(8,5);
hold on;
x = [0:(length(l)-1)]*1024/22050;
plot(x,(l-1)*1024/22050); xlabel('Start Time in Song(s)'); ylabel('End Time in Song(s)');
title('DTW Path Start Function')
axis([0 140 0 140])
set(fig, 'PaperUnits','centimeters','PaperSize', [8 5], 'PaperPositionMode', 'manual','Paperposition',[0 0 8 5]);
print(fig,'plots_ISMIR2017/step.pdf','-dpdf')