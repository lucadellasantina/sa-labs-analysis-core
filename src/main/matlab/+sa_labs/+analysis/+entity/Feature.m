classdef Feature < handle & matlab.mixin.Heterogeneous
    
    properties(SetAccess = protected)
        description
    end
    
    properties
        id
        data
    end
    
    methods
        
        function obj = Feature(desc, data)
            if nargin < 2
                data = [];
            end            
            obj.description = desc;
            obj.data = data;
        end
        
        function appendData(obj, value)
            
            if isscalar(value)
                obj.data(end + 1) = value;
            elseif iscell(value)
                obj.data = addToCell(obj.data, value);
            else
                obj.data = [obj.data, value];
            end
        end
    end
end

