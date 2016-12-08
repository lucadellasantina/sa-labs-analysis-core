classdef FeatureIdentifier < handle
    
    properties
        description
    end
    
    methods
        
        function obj = FeatureIdentifier(metaClass, units)
            obj.description = sa_labs.analysis.entity.FeatureDescription();
            obj.description.clazz = metaClass.Name;
            obj.description.units = units;
            obj.description.type = obj;
        end
    end
    
end

