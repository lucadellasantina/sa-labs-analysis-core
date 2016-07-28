classdef Node < handle & matlab.mixin.CustomDisplay
    
    properties
        id
        name
        splitParameter
        splitValue
        parameters
        epochIndices
        featureMap
        plotHandles
    end
    
    methods
            
        function setParameters(obj, parameters)
            names = fieldnames(parameters);
            for i = 1 : length(names)
                obj.setParameter(names{i}, parameters.(names{i}));
            end
        end
        
        function tf = hasParameter(obj, parameter)
            tf = isprop(obj, parameter) || isprop(obj.parameters, parameter);
        end
        
        function setParameter(obj, property, value)
            if isprop(obj, property)
                obj.(property) = value;
            else
                obj.parameters.(property) = value;
            end
        end
        
        function feature = getFeature(obj, featureDescription)
            key = featureDescription.type;
            
            if isKey(obj.featureMap, key)
               feature = obj.featureMap(key);
               return
            end
            obj.featureMap(key) = Feature.create(featureDescription);
        end
        
        function appendFeature(obj, key, value)
            if isscalar(value)
                obj.features(key).data(end + 1) = value;
            else
                old = obj.features(key).data;
                new = [old, value];
                obj.features(key).data = new;
            end
        end
    end
    
end

