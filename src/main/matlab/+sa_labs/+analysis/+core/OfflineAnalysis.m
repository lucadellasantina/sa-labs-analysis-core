classdef OfflineAnalysis < sa_labs.analysis.core.Analysis
    
    properties (Access = private)
    end

    properties
        mode = sa_labs.analysis.core.AnalysisMode.OFFLINE_ANALYSIS;
    end
    
    properties (Constant)
        DEFAULT_ROOT_ID = 1;
    end
    
    methods
        
        function obj = OfflineAnalysis(project)
            obj@sa_labs.analysis.core.Analysis(project);
        end

        function init(obj, analysisProtocol)
            init@sa_labs.analysis.core.Analysis(obj, analysisProtocol);
            obj.extractor.epochStream = @(indices) obj.project.cellData.epochs(indices);
        end
    end
    
    methods (Access = protected)
        
        function build(obj)
            cellData = obj.project.cellData;

            for pathIndex = 1 : obj.analysisProtocol.numberOfPaths()
                numberOfEpochs = numel(cellData.epochs);
                epochGroup = sa_labs.analysis.entity.EpochGroup(1 : numberOfEpochs, cellData.identifier);
                parameters = obj.analysisProtocol.getSplitParametersByPath(pathIndex);
                obj.add(obj.DEFAULT_ROOT_ID, epochGroup, parameters);
            end
        end
        
        function p = getFilterParameters(obj)
            p = obj.analysisProtocol.getSplitParameters();
        end
        
        function featureGroups = getFeatureGroups(obj, parameter)
            featureGroups = obj.featureManager.findFeatureGroup(parameter);
        end
        
        function copyEpochParameters(obj, featureGroups)
            
            if obj.featureManager.isBasicFeatureGroup(featureGroups)
                obj.setEpochParameters(featureGroups);
            end
            keySet = obj.project.cellData.getEpochKeysetUnion([featureGroups.epochIndices]);

            if isempty(keySet)
                disp('[WARN] keyset is empty, cannot percolate up epoch parameters');
                return
            end
            obj.featureManager.copyFeaturesToGroup([featureGroups.id], keySet, keySet);
        end
    end
    
    methods (Access = private)
        
        function add(obj, parentId, epochGroup, params)
            splitBy = params{1};
            cellData = obj.project.cellData;

            [epochValueMap, filter] = cellData.getEpochValuesMap(splitBy, epochGroup.epochIndices);
            splitValues = obj.analysisProtocol.validateSplitValues(splitBy, epochValueMap.keys);
            
            if isempty(splitValues) && length(params) > 1
                obj.featureManager.removeFeatureGroup(parentId);
            end
            
            for i = 1 : length(splitValues)
                splitValue = splitValues{i};
                epochIndices = epochValueMap(splitValue);
                
                if isempty(epochIndices)
                    continue
                end
                
                epochGroup = sa_labs.analysis.entity.EpochGroup(epochIndices, filter, splitValue);
                if ~ isempty(epochGroup)
                    id = obj.featureManager.addFeatureGroup(parentId, splitBy, splitValue, epochGroup);
                end
                
                if length(params) > 1
                    obj.add(id, epochGroup, params(2 : end));
                end
            end
        end
        
        function setEpochParameters(obj, featureGroups)
            cellData = obj.project.cellData;
            
            for i = 1 : numel(featureGroups)
                [p, v] = cellData.getUniqueParamValues(featureGroups(i).epochIndices);
                
                if isempty(p)
                    disp(['[WARN] no epoch parameter found for given node ' num2str(featureGroups(i).id)]);
                    continue;
                end
                featureGroups(i).setParameters(containers.Map(p, v));
            end
        end
    end
end