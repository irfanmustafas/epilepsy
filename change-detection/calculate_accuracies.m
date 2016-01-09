function [tp, fp, fn, n] = calculate_accuracies(plotdata, labels)

blink_length = 10;
lookahead = 1;
tp = 0;

detections = plotdata.pts > plotdata.ucl | plotdata.pts < plotdata.lcl;
blinks = [0; diff(labels)];
n = sum(blinks==1);
detections = [0; diff(detections)];
blinks = [0; diff(labels)];
sequences = [find(blinks==1) find(blinks==-1)];

for i=1:size(sequences,1)
    start = sequences(i,1);
    finish = sequences(i,2);
    i
    start-lookahead:finish+blink_length
    window = detections(start-lookahead:finish+blink_length);
    
    if(sum(window==1) >= 1)
        tp = tp + 1;
    end
end
fn = size(sequences,1)-tp;
fp = sum(detections==1)-n;

%fprintf('%.2f%% (%d/%d) blinks registered\n',(tp/n)*100, tp, n);
end
