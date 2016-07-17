classdef EpochData < handle
    
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
end