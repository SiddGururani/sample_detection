function generate_ashis_figure(cdata1)
%CREATEFIGURE(CDATA1)
%  CDATA1:  image cdata

%  Auto-generated by MATLAB on 27-Feb-2018 14:31:14

% Create figure
figure1 = figure;
colormap(gray);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create image
image(cdata1,'Parent',axes1,'CDataMapping','scaled');

% Uncomment the following line to preserve the X-limits of the axes
xlim(axes1,[0.5 8.5]);
% Uncomment the following line to preserve the Y-limits of the axes
ylim(axes1,[0.5 8.5]);
box(axes1,'on');
axis(axes1,'ij');
% Set the remaining axes properties
set(axes1,'FontSize',20,'Layer','top','XAxisLocation','top','XTick',...
    [1 2 3 4 5 6 7 8],'XTickLabel',...
    {'s-M','s-N','s-R','s-T','m-M','m-N','m-R','m-T'},'YTickLabel',...
    {'s-M','s-N','s-R','s-T','m-M','m-N','m-R','m-T'});
% Create colorbar
colorbar('peer',axes1);

