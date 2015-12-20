load('labels.mat')

difference_t = [0; diff(labels)];
blinks = [find(difference_t==1) find(difference_t==-1)];

difference_d = [0; diff(st)];
detected = [find(difference_d==1) find(difference_d==-1)];

tp = 0; fn = 0;
for i=1:size(blinks,1)
    
    true_sequence = blinks(i,1):blinks(i,2);
    
    was_detected = 0;
    
    for j = 1:size(detected,1)
        
        predicted_sequence = detected(j,1):detected(j,2);
        
        intersection = intersect(true_sequence,predicted_sequence);
        
        if ~isempty(intersection)
            was_detected = 1;
            break;
        end
    end
    
    if was_detected
        tp = tp + 1;
    else
        fn = fn + 1;
    end
end

nBlinks = size(blinks,1);
nDetected = size(detected,1);

fprintf('\n%d/%d detected (%.2f%%)\n', tp, nBlinks, (tp/nDetected)*100);