classdef Node < handle
    
    properties
        id
        name
        splitParameter
        splitValue
        parameters
        epochIndices
        features
        extractor
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
    end
    
end

