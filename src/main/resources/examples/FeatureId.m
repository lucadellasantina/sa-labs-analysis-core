classdef FeatureId < handle
    
    enumeration
        MEAN_RESPONSE(?AcrossEpochFeature, 'sec')                               % Mean response of all the epochs
        SPIKE_AMP(?sa_labs.analysis.entity.Feature, 'pA')
        SPIKE_TIMES(?sa_labs.analysis.entity.Feature, 'sec')
        
        AVERAGE_WAVE_FORM(?AcrossEpochFeature, 'todo')
        TEST_FEATURE(?sa_labs.analysis.entity.Feature, 'unknown')
        TEST_SECOND_FEATURE(?sa_labs.analysis.entity.Feature, 'unknown')
    end
    
    properties
        description
    end
    
    methods
        
        function obj = FeatureId(metaClass, units)
            obj.description = sa_labs.analysis.entity.FeatureDescription();
            obj.description.clazz = metaClass.Name;
            obj.description.units = units;
            obj.description.type = obj;
        end
    end
    
end

