function [blink_start_indices, detected_start_indices, blink_end_indices, detected_end_indices] = frames_to_sequences(labels, detections, give_factor)

if nargin < 3
    give_factor = 5;
end

l = find(labels)'; d = find(detections)';
ll = find(diff(l)>give_factor); dd = find(diff(d)>give_factor); 
blink_start_indices = l([1 ll+1]); 
detected_start_indices = d([1 dd+1]);% beginnings of blinks

blink_end_indices = [l(ll) l(end)]; 
detected_end_indices = [d(dd) d(end)];% end of blinks

end