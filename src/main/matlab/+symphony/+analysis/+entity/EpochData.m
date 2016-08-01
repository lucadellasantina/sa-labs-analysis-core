classdef EpochData < handle & matlab.mixin.CustomDisplay
    
    properties
        attributes            % Map holding protocol and epoch attributes from h5 data
        parentCell            % parent cell
    end
    
    properties (Hidden)
        dataLinks             % Map with keys as Amplifier device and values as responses
        responseHandle        % amplifere response call back argumet as stream name
    end
    
    methods
        
        function value = get(obj, name)
            % Returns the matching value for given name from attributes map
            
            value = [];
            if obj.attributes.isKey(name)
                value = obj.attributes(name);
            end
        end
        
        function modes = getMode(obj, modeType)
            % getMode - Returns the available amplifer mode for given
            % search string
            %
            % Pattern matches all the attributes for given modeType.
            % If found returns the equivalent value
            %
            % usage :
            %       getMode('mode')
            %       getMode('Amp2Mode')
            
            parameters = regexpi(obj.attributes.keys, ['\w*' modeType '\w*'], 'match');
            parameters = [parameters{:}];
            modes = cell(0, numel(parameters));
            
            for i = 1 : numel(parameters)
                modes{i} = obj.attributes(parameters{i});
            end
        end
        
        function r = getResponse(obj, device)
            % getResponse - finds the device response by executing call back
            % 'responseHandle(path)'
            % path - is obtained from dataLinks by matching it with given
            % device @ see symphony2parser.parse() method for responseHandle
            % definition
            
            if ~ isKey(obj.dataLinks, device)
                error('device:notfound', ['device name [ ' device ' ] not found in the h5 response']);
            end
            
            path = obj.dataLinks(device);
            r = obj.responseHandle(path);
        end
        
        function attributeKeys = unionAttributeKeys(obj, attributeKeys)
            % unionAttributeKeys - returns the union of { current instance 
            % attribute keys } and passed argument {attributeKeys}
            
            if isempty(attributeKeys)
                attributeKeys = obj.attributes.keys;
                return
            end
            
            attributeKeys = union(attributeKeys, obj.attributes.keys);
        end
    end
    
    methods(Access = protected)
        
        function header = getHeader(obj)
            try
                type = obj.parentCell.cellType;
                if isempty(type)
                    type = 'unassigned';
                end
                header = ['Displaying epoch information of [ ' type ' ] cell type '];
            catch
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            end
        end
        
        function groups = getPropertyGroups(obj)
            try
                attrKeys = obj.attributes.keys;
                deviceKeys = obj.dataLinks.keys;
                groups = matlab.mixin.util.PropertyGroup.empty(0, 2);
                
                display = struct();
                for i = 1 : numel(attrKeys)
                    display.(attrKeys{i}) = obj.attributes(attrKeys{i});
                end
                groups(1) = display;
                groups(2) = deviceKeys;
            catch
                groups = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            end
        end
    end
end