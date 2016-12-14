classdef FeatureDescription < dynamicprops
    
    properties
        id
        description
        strategy
        unit
        chartType
        xAxis
    end
    
    methods
        
        function obj = FeatureDescription(map)
            
            props = map('properties');
            map = remove(map, 'properties');
            cellfun(@(k) obj.set(k, map(k)), map.keys);
            
            if  isempty(props)
                return
            end
            props = strsplit(props, ',');
            
            for i = 1 : numel(props)
                props = strrep(props, '"', '');
                prop = strsplit(props{i}, '=');
                obj.set(prop{1}, prop{2});
            end
        end
    end
    
    methods (Access = private)
        
        function set(obj, k, v)
            
            if ~ isempty(k)
                var = strtrim(k);
                
                if ~ isprop(obj, var)
                    addprop(obj, var);
                end
                % TODO check for data type of v and convert to appropriate
                obj.(var) = strtrim(v);
            end
        end
    end
end

