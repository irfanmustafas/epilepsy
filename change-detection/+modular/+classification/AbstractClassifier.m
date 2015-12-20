classdef AbstractClassifier < handle
    %ABSTRACTCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here

    methods(Abstract)
        train(data, labels)
        class = classify(data)
    end
    
end

