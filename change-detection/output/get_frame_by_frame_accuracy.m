function [accuracy, cm] = get_frame_by_frame_accuracy(labels, detections, give_factor)

[labels_smooth,detections_smooth] = deal(zeros(1,numel(labels)));
[bl,bd,el,ed] = frames_to_sequences(labels, detections, give_factor);

for i = 1:numel(bl)
    labels_smooth(bl(i):el(i)) = 1;
end
for i = 1:numel(bd)
    detections_smooth(bd(i):ed(i)) = 1;
end

accuracy = mean(labels_smooth == detections_smooth);
[~,cm] = confusion(labels_smooth, detections_smooth);

end