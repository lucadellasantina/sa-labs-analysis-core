classdef AcrossEpochFeature < sa_labs.analysis.entity.Feature
    
    properties
        count
        size
    end
    
    methods
        
        function mean(obj, data)
            obj.data = obj.add(data) / obj.count;
            obj.count = obj.count + 1;
        end
        
    end
    
end

