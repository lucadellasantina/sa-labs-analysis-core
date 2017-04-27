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

        function obj = EpochData()
            obj.attributes = containers.Map();
            obj.dataLinks = containers.Map();
        end
        
        function value = get(obj, name)
            % Returns the matching value for given name from attributes map
            
            value = [];
            if obj.attributes.isKey(name)
                value = obj.attributes(name);
            end
        end
        
        function [keys, values] = getParameters(obj, pattern)
            % keys - Returns the matched parameter for given
            % search string
            %
            % values - Returns the available parameter values for given
            % search string
            %
            % Pattern matches all the attributes from epoch and  celldata.
            % If found returns the equivalent value
            %
            % usage :
            %       getParameters('chan1')
            %       getParameters('chan1Mode')
            
            parameters = regexpi(obj.attributes.keys, ['\w*' pattern '\w*'], 'match');
            parameters = [parameters{:}];
            values = cell(0, numel(parameters));
            keys = cell(0, numel(parameters));
            
            for i = 1 : numel(parameters)
                keys{i} = parameters{i};
                values{i} = obj.attributes(parameters{i});
            end
            
            parameters = regexpi(obj.parentCell.attributes.keys, ['\w*' pattern '\w*'], 'match');
            parameters = [parameters{:}];
            for i = 1 : numel(parameters)
                keys{end + i} = parameters{i};
                values{end + i} = obj.parentCell.attributes(parameters{i});
            end
        end
        
        function r = getResponse(obj, device)
            % getResponse - finds the device response by executing call back
            % 'responseHandle(path)'
            % path - is obtained from dataLinks by matching it with given
            % device @ see symphony2parser.parse() method for responseHandle
            % definition
            
            if ~ isKey(obj.dataLinks, device)
                devices = cellstr(obj.dataLinks.keys);
                message = ['device name [ ' device ' ] not found in the h5 response. Available device [' [devices{:}] ']'];
                error('device:notfound', message);
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