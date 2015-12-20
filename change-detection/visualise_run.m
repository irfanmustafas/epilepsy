clc;
close all;

figure; hold on;

hold on;
stat = plot(2*st/(max(st))-1);
axis([1,size(st,1), -2, 2]);


trueLabels = plot(find(labels==2), -1.1, 'go');
detections = plot(changeFrames, -1.3, 'ro');

legend('Statistic', 'True Labels')

