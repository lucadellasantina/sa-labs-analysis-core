classdef Exceptions < handle
    
    enumeration
        NO_CELL_DATA('createProject:nocellData', 'cell data not found. Please run parser and try again')
        NO_PROJECT('findProject:noProjectFound', 'project not found. check the project name and try again')
        NO_DATA_SET_FOUND('buildTree:noEpochGroup', 'No data set found for specified split value')
        SPLIT_VALUE_NOT_FOUND('validateLevel:splitValueNotFound', 'No matching split value while building the tree')
        MISMATCHED_EXTRACTOR_TYPE('extractorType:invalid', ['instance is not of type' sa_labs.analysis.core.FeatureExtractor.CLASS]);
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
        
        function e = create(obj)
            e = MException(obj.msgId, obj.description);
        end
        
    end
end

