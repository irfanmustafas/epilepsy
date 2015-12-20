function queueMatrix = addMatrixToQueue(queueMatrix, newMatrix, maxSizeQueue)

if (isempty(queueMatrix))
    queueMatrix = newMatrix;
else
    queueMatrix(:, :, end + 1) = newMatrix;
end

if (size(queueMatrix, 3) > maxSizeQueue)
    queueMatrix(:, :, 1) = [];
end

