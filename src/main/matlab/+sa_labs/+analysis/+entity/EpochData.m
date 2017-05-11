classdef EpochData < sa_labs.analysis.entity.KeyValueEntity
    
    properties
        parentCell            % parent cell
    end
    
    properties (Hidden)
        dataLinks             % Map with keys as Amplifier device and values as responses
        responseHandle        % amplifere response call back argumet as stream name
        derivedAttributes     % like spikes and other epoch specific pre-processed data  
    end
    
    methods

        function obj = EpochData()
            obj.attributes = containers.Map();
            obj.dataLinks = containers.Map();
            obj.derivedAttributes = containers.Map();
        end
        
        function v = get(obj, key)
            v = get@sa_labs.analysis.entity.KeyValueEntity(obj, key);
            
            if isempty(v) && strcmpi(key, 'devices')
                v = obj.dataLinks.keys;
            elseif isempty(v) && obj.derivedAttributes.isKey(key)
                v = obj.derivedAttributes(key);
            elseif isempty(v)
                [~, v] = obj.getParameters(key);
            end
        end

        function add(obj, id, data)
            obj.derivedAttributes(id) = data;
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
            
            [keys, values] = getParameters@sa_labs.analysis.entity.KeyValueEntity(obj, pattern);
            
            if ~ isempty(obj.parentCell)
                [parentKeys, parentValues] = obj.parentCell.getParameters(pattern);
                keys = [keys, parentKeys];
                values = [values, parentValues];
            end
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
    end
end