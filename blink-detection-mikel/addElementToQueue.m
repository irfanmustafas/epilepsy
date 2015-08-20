function queueVector = addElementToQueue(queueVector, newElement, maxSizeQueue)

if (isempty(queueVector))
    queueVector = newElement;
else
    queueVector(end + 1) = newVector;
end

if (length(queueVector) > maxSizeQueue)
    queueVector(1) = [];
end

