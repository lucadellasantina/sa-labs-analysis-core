classdef FeatureManager < handle
    
    properties
        analysisProtocol
        analysisMode
        descriptionMap
        epochStream
    end
    
    properties (Abstract)
        dataStore
    end
    
    properties (Constant)
        
        % Format specifier description
        % ----------------------------------------------------------------------------
        % 'id', 'description', 'strategy', 'unit', 'chartType', 'xAxis', 'properties'
        % ----------------------------------------------------------------------------
        
        FORMAT_SPECIFIER = '%s%s%s%s%s%s%s%[^\n\r]';
    end
    
    methods
        
        function obj = FeatureManager(analysisProtocol, analysisMode, dataStore)
            obj.analysisProtocol = analysisProtocol;
            obj.analysisMode = analysisMode;
            obj.dataStore = dataStore;
            
            obj.loadFeatureDescription(analysisProtocol.featureDescriptionFile);
        end
        

        function epochs = getEpochs(obj, featureGroup)
            
            if obj.analysisMode.isOnline()
                epochs = obj.epochStream;
                return
            end
            % If the epoch Indices are not present in the EpochGroup it will
            % throw an error
            epochs = obj.epochStream(featureGroup.epochIndices);
        end
        
        function loadFeatureDescription(obj, descriptionFile)
            import sa_labs.analysis.*;
            
            if ~ isempty(obj.descriptionMap)
                warning('featureManager:reloadDescriptionCSV', ['reloading descriptionMap from file ' descriptionFile])
            end
            text = util.file.readCSVToCell(descriptionFile, obj.FORMAT_SPECIFIER);
            
            % get the first column and use it as key for descriptionMap
            vars = text(:, 1);
            header = text(1, :);
            obj.descriptionMap = containers.Map();
            
            % skip the header rows
            for i = 2 : numel(vars)
                key = strtrim(vars{i});
                desc = entity.FeatureDescription(containers.Map(header, text(i, :)));
                obj.descriptionMap(key) = desc;
            end
        end
        
        % TODO test
        function updateFeatureDescription(obj, featureGroups)
            import sa_labs.analysis.*;
            keySet = featureGroups.getFeatureKey();
            
            for i = 1 : numel(keySet)
                key = keySet{i};
                features = featureGroups.featureMap(key);
                
                if ~ isKey(obj.descriptionMap, key)
                    obj.descriptionMap(key) = features(1).description;
                    entity.FeatureDescription.cacheMap(obj.descriptionMap);
                end
                
            end
        end
        
        function saveFeatureDescription(obj)
            % TODO update the CSV file
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
