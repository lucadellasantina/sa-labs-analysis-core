classdef Exceptions < handle
    
    enumeration
        NO_CELL_DATA('createProject:nocellData', 'cell data not found. Please run parser and try again')
        NO_DATA_SET_FOUND('buildTree:noDataSet', 'No data set found for specified split value')
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

