%% Novelty function: peak envelope
% [nvt] = myPeakEnv(x, w, windowSize, hopSize)
% input: 
%   x: N by 1 float vector, input signal
%   windowSize: int, number of samples per block
%   hopSize: int, number of samples per hop
% output: 
%   nvt: n by 1 float vector, the resulting novelty function 

function [nvt] = myPeakEnv(x, windowSize, hopSize)

% Padding zeros to signal for window centering
x = [zeros(windowSize/2-1,1); x];

%Padding zeros to signal if not appropriate size for blocking.
if(mod(numel(x)-windowSize,hopSize)~=0)
	pad = zeros(hopSize-mod(numel(x)-windowSize,hopSize),1);
	x = [x; pad];
end

%Initialize a matrix for all outputs.
numBlocks = floor((numel(x)-windowSize)/hopSize+1);
peaks_0 = zeros(numBlocks,1);

for i=1:numBlocks
    window = hann(windowSize).*x(hopSize*(i-1)+1:hopSize*(i-1)+windowSize);
    peaks_0(i) = max(abs(window));
end

nvt =  peaks_0;


% figure;
% time_in_sec = [1:length(nvt)]*hopSize/44100;
% plot(time_in_sec,nvt)
% % hold on
% % plot(true_onset_time,true_onset_value)
% xlabel('Time (s)')
% ylabel('Novelty')
% title(['Output of ' mfilename ' for x2.wav'])
% xlim([0 2])
% saveas(gcf,['../Report/Figures/' mfilename 'x2.jpg'],'jpg')
% saveas(gcf,['../Report/Figures/' mfilename 'x2.fig'],'fig')

end