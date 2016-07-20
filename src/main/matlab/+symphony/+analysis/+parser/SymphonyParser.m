classdef SymphonyParser < handle
    
    properties
        fname
    end
    
    methods
        
        function map = mapAttributes(obj, h5group, map)
            if nargin < 3
                map = containers.Map();
            end
            if ischar(h5group)
                h5group = h5info(obj.fname, h5group);
            end
            attributes = h5group.Attributes;
            
            for i = 1 : length(attributes)
                name = attributes(i).Name;
                root = strfind(name, '/');
                
                if ~ isempty(root)
                    name = attributes(i).Name(root(end) + 1 : end);
                end
                    map(name) = attributes(i).Value;
            end
        end
        
    end
    
    methods(Abstract)
        parse(obj)
        getResult(obj)
    end
    
    methods(Static)
        
        function version = getVersion(fname)
             version = h5readatt(fname, '/', 'version');
        end
    end
end

