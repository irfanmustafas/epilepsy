function [ accuracy, n_gt, n_d ] = get_sequence_accuracy( labels, detections, give_factor, linger_factor )
    [bl,bd,el,ed] = frames_to_sequences(labels, detections, give_factor);
    
    n_gt = size(bl,2);
    n_d = size(bd,2);
    tp=0;
    for i=1:n_gt

        gt_seq = bl(i):el(i);
        dt_seq = bd(i):ed(i);

        overlaps = numel(intersect(gt_seq, dt_seq)) > 0;
        lingers = ed(i)-el(i) >= linger_factor;

        if (overlaps && ~lingers)
            tp = tp + 1;
        end

    end
    
    accuracy = tp / n_gt;
end

