%Run evaluation_bigset until 1 sample is loaded, then run this

[~, c] = dtw_minima(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2, 100, 50);
figure;
plot(c(end,:));
title('Last row cost(sample:10, mix:50)');


[~, c] = dtw_minima(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2, 50, 50);
figure;
plot(c(end,:));
title('Last row cost(sample:50, mix:50)');


[~, c] = dtw_minima(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2, 10, 100);
figure;
plot(c(end,:));
title('Last row cost(sample:10, mix:100)');


[~, c] = dtw_minima(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2, 50, 100);
figure;
plot(c(end,:));
title('Last row cost(sample:50, mix:100)');


% [~, c] = dtw_minima(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2, 10, 200);
% figure;
% plot(c(end,:));
% title('Last row cost(sample:10, mix:200),new norm');
% 
% 
% [~, c] = dtw_minima(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2, 50, 200);
% figure;
% plot(c(end,:));
% title('Last row cost(sample:50, mix:200),new norm');