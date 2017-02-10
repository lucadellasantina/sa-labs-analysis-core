classdef FeatureDescription < dynamicprops
    
    properties
        id
        description
        strategy
        unit
        chartType
        xAxis
        downSampleFactor
    end
    
    methods
        
        function obj = FeatureDescription(map)
            props = [];
            
            if isKey(map, 'properties')
                props = map('properties');
                map = remove(map, 'properties');
            end
            cellfun(@(k) obj.set(k, map(k)), map.keys);
            
            if isempty(props)
                return
            end
            
            obj.setProperties(props);
        end
        
        function setProperties(obj, props)
            import  sa_labs.analysis.app.*;

            props = strsplit(props, ',');
            
            for i = 1 : numel(props)
                props = strrep(props, '"', '');
                prop = strsplit(props{i}, '=');
                
                if numel(prop) == 2
                    obj.set(prop{1}, prop{2});
                else
                    Exceptions.INVALID_PROPERTY_PAIR.create('warning', true);
                end
            end
        end
    end
    
    methods (Access = private)
        
        function set(obj, k, v)
            try
                if ~ isempty(k)
                    var = strtrim(k);
                    
                    if ~ isprop(obj, var)
                        addprop(obj, var);
                    end
                    % TODO check for data type of v and convert to appropriate
                    obj.(var) = strtrim(v);
                end
            catch exception
                warning(exception.identifier, exception.message)
            end
        end
    end
    
    methods (Static)
        
        function descriptionMap = cacheMap(descriptionMap)
            
            persistent map;
            
            if nargin < 1
                descriptionMap = map;
                return
            end
            map = descriptionMap;
        end
        
        function tf = isPresent(id)
            map = sa_labs.analysis.entity.FeatureDescription.cacheMap();
            tf = isKey(map, id);
        end
        
    end
end

