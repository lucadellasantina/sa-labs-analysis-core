classdef Exceptions < handle
    
    enumeration
        NO_CELL_DATA('createProject:nocellData', @(msg) [ msg ' not found. Please run parser and try again '])
        NO_PROJECT('findProject:noProjectFound', @(msg) [ msg ' not found. check the project name and try again '])
        
        NO_DATA_SET_FOUND('buildTree:noEpochGroup', @(msg) ['No data set found for split value = ' msg ])
        SPLIT_VALUE_NOT_FOUND('validateLevel:splitValueNotFound', @(msg) ['No matching split value = ' msg ' while building the tree' ])

        MULTIPLE_FEATURE_KEY_PRESENT('getFeatureData:multipleFeatureIdErr', @(msg) 'cannot fetch features. Supplied feature ids are different')
        FEATURE_KEY_NOT_FOUND('getFeatureData:featureIdNotPresent', @(msg)['Feature Id ' msg ' is not found in the feature map']);

        INVALID_PROPERTY_PAIR('properties:invalid', @(msg) 'properties deos not have valid param value pair');
        
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
            ip.addParameter('message', '', @ischar);
            ip.parse(varargin{:});
            e = [];
            message = obj.description(ip.Results.message);
            if ip.Results.warning;
                warning(obj.msgId, message);
                return
            end
            e = MException(obj.msgId, message);
        end
        
    end
end

