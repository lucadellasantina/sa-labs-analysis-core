classdef Feature < handle & matlab.mixin.Heterogeneous
    
    properties
        name
        type
        units
        data
        description
    end
    
    methods
        
        function add(obj, data)
            
            if isempty(obj.data)
                obj.data = zeros(size(data));
            end
            obj.data = obj.data + data;
        end
        
        function divideBy(obj, factor)
            if isa(parameter, 'function_handle')
                factor = factor(obj.data);
            end
            obj.data = obj.data / factor;
        end
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

