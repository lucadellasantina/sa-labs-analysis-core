classdef AcrossEpochFeature < symphony.analysis.core.Feature
    
    properties
        count
        size
    end
    
    methods
        
        function mean(obj, data)
            
            if isempty(obj.data)
                obj.data = zeros(1, data);
            end
            obj.data = (obj.data + data)/ obj.count;
            obj.count = obj.count + 1;
        end
    end
    
end

