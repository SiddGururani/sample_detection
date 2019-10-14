%plot stuff

fig = generateFigure(8,3);
hold on;
x = [0:size(D,2)-1]*hop/fs;
y = [0:size(D,1)-1]*hop/fs;
imagesc(x, y, D);
set(gca, 'layer', 'top','Ydir','reverse');
grid off
colorbar;
xlim([0 20])
ylim([0,3.8])
xlabel('Time in Song(s)'); ylabel('Time in Sample(s)');
title('Distance matrix showing alignment paths');
set(fig, 'PaperUnits','centimeters','PaperSize', [8 3], 'PaperPositionMode', 'manual','Paperposition',[0 0 8 3]);
print(fig,'plots_ISMIR2017/distmat.pdf','-dpdf')