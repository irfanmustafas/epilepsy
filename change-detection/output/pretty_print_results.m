function pretty_print_results(labels, detections)

give_factor = 5;
linger_factor = 6;

[bl,bd,el,ed] = frames_to_sequences(labels, detections, give_factor);
fprintf('\nBlink beginning and end (frame number)\n')
fprintf('--------------------------------------\n')
fprintf('Beginning TRUE     '),fprintf('%i ',bl),fprintf('\n')
fprintf('Ending TRUE        '),fprintf('%i ',el),fprintf('\n')
fprintf('--------------------------------------\n')
fprintf('Beginning DETECTED '),fprintf('%i ',bd),fprintf('\n')
fprintf('Ending DETECTED    '),fprintf('%i ',ed),fprintf('\n\n')

[fxf, cm] = get_frame_by_frame_accuracy(labels, detections, give_factor);
[seq, n, d] = get_sequence_accuracy(labels, detections, give_factor, linger_factor);

fprintf('Blinks detected: %.02f%% (%d/%d)\n', seq*100, d, n)
fprintf('Frame by frame accuracy: %.02f%%\n', fxf*100)
cm


end
