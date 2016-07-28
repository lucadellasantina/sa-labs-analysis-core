classdef Feature < handle & matlab.mixin.Heterogeneous
    
    properties
        id
        name
        type
        units
        data
    end
    
    methods(Static)
        
        function obj = create(featureDescription)
            constructor = str2func(featureDescription.clazz);
            obj = constructor();
        end
    end
    
end

