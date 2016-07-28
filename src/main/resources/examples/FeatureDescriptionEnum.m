classdef FeatureDescriptionEnum < symphony.analysis.core.FeatureDescription

    enumeration
        MEAN_RESPONSE(?AcrossEpochFeature, 'sec');      % Mean response of all the epochs
        SPIKE_AMP(?Feature, 'pA');
        SPIKE_TIMES(?Feature, 'sec');
        AVERAGE_WAVE_FORM(?AcrossEpochFeature, 'todo')
    end
    
    properties
        clazz
        units
        type
    end
    
    methods
        
        function obj = FeatureDescriptionEnum(metaClass, units)
            obj.clazz = metaClass.Name;
            obj.units = units;
            obj.type = obj;
        end
    end
    
end

