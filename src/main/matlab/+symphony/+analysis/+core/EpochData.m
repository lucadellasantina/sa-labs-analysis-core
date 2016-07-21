classdef EpochData < handle & matlab.mixin.CustomDisplay
    
    properties
        attributes      % Map holding protocol and epoch attributes from h5 data
        parentCell      % parent cell
    end
    
    properties (Hidden)
        dataLinks       % Map with keys as Amplifier device and values as responses
        response        % amplifere response call back argumet as stream name
    end
    
    methods
        
        function value = get(obj, name)
            value = Nan;
            if obj.attributes.isKey(name)
                value = obj.attributes(name);
            end
        end
        
        function modes = getMode(obj)
            modes = regexpi(obj.attributes.keys, '\w*mode\w*', 'match');
            modes = [modes{:}];
        end
        
        function r = getResponse(obj, device)
            r = obj.response(device);
        end
    end
    
    methods(Access = protected)
        
        function header = getHeader(obj)
            type = obj.parentCell.cellType;
            if isempty(type)
                type = 'unassigned';
            end
            header = ['Displaying epoch information of ' type ' cell type '];
        end
        
        function groups = getPropertyGroups(obj)
            attrKeys = obj.attributes.keys;
            deviceKeys = obj.dataLinks.keys;
            groups = matlab.mixin.util.PropertyGroup.empty(0, 2);
            
            display = struct();
            for i = 1 : numel(attrKeys)
                display.(attrKeys{i}) = obj.attributes(attrKeys{i});
            end
            groups(1) = display;
            groups(2) = deviceKeys;
        end
    end
end