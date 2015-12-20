classdef SVMClassifier < modular.classification.AbstractClassifier
    %SVMCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model
    end
    
    methods
        function train(this, data, labels)
            this.model = fitcsvm(data, labels);
        end
        
        function class = classify(this, data)
            class = predict(this.model, data);
        end
    end
    
end

