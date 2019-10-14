fig = generateFigure(8,5);
hold on;
x = [0:(length(l)-1)]*1024/22050;
plot(x,l); xlabel('Time (s)'); ylabel('DTW Cost');
axis([0 140 0 1.1])
title('DTW Cost Function')
set(fig, 'PaperUnits','centimeters','PaperSize', [8 5], 'PaperPositionMode', 'manual','Paperposition',[0 0 8 5]);
print(fig,'plots_ISMIR2017/cost.pdf','-dpdf')