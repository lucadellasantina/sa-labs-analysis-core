classdef FeatureId < handle
    
    enumeration
        MEAN_RESPONSE(?AcrossEpochFeature, 'sec')                          % Mean response of all the epochs
        SPIKE_AMP(?symphony.analysis.entity.Feature, 'pA')
        SPIKE_TIMES(?symphony.analysis.entity.Feature, 'sec')
        AVERAGE_WAVE_FORM(?AcrossEpochFeature, 'todo')
        TEST_FEATURE(?symphony.analysis.entity.Feature, 'unknown')
        TEST_SECOND_FEATURE(?symphony.analysis.entity.Feature, 'unknown')
    end
    
    properties
        description
    end
    
    methods
        
        function obj = FeatureId(metaClass, units)
            obj.description = symphony.analysis.entity.FeatureDescription();
            obj.description.clazz = metaClass.Name;
            obj.description.units = units;
            obj.description.type = obj;
        end
    end
    
end

