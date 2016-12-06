classdef Feature < handle & matlab.mixin.Heterogeneous
    
    properties
        name
        type
        units
        data
        description
        features
        appendingIndex
    end
    
    methods(Static)
        
        function obj = create(featureDescription)
            constructor = str2func(featureDescription.clazz);
            obj = constructor();
            obj.name = char(featureDescription.type);
            obj.type = featureDescription.clazz;
            obj.units = featureDescription.units;
            obj.description = featureDescription;
        end
    end
    
end

