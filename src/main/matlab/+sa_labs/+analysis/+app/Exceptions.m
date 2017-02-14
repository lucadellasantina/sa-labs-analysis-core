classdef Exceptions < handle
    
    enumeration
        NO_CELL_DATA('createProject:nocellData', 'cell data not found. Please run parser and try again')
        NO_PROJECT('findProject:noProjectFound', 'project not found. check the project name and try again')
        NO_DATA_SET_FOUND('buildTree:noEpochGroup', 'No data set found for specified split value')
        SPLIT_VALUE_NOT_FOUND('validateLevel:splitValueNotFound', 'No matching split value while building the tree')
        MULTIPLE_FEATURE_KEY_PRESENT('getFeatureData:multipleFeatureIdErr', 'cannot fetch features as the supplied feature ids are different')
        FEATURE_KEY_NOT_FOUND('getFeatureData:featureIdNotPresent', 'Feature Id is not found in the feature map');
        MISMATCHED_FEATURE_MANAGER_TYPE('extractorType:invalid', 'instance is not of type  sa_labs.analysis.core.FeatureManager');
        INVALID_PROPERTY_PAIR('properties:invalid', 'properties deos not have valid param value pair');
        
    end
    
    properties
        msgId
        description
    end
    
    methods
        
        function obj = Exceptions(id, desc)
            obj.msgId = id;
            obj.description = desc;
            
        end
        
        function e = create(obj, varargin)
            ip = inputParser;
            ip.addParameter('warning', false, @islogical);
            ip.parse(varargin{:});
            e = [];
            
            if ip.Results.warning;
                warning(obj.msgId, obj.description);
                return
            end
            e = MException(obj.msgId, obj.description);
        end
        
    end
end

