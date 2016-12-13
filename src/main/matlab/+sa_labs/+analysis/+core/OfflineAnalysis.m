classdef OfflineAnalysis < sa_labs.analysis.core.Analysis
    
    properties (Access = private)
        cellData
        resultManager
    end
    
    properties (Constant)
        DEFAULT_ROOT_ID = 1;
    end
    
    methods
        
        function obj = OfflineAnalysis()
            obj@sa_labs.analysis.core.Analysis();
            obj.resultManager = sa_labs.analysis.core.NodeManager();
            obj.resultManager.setRootName('result');
        end

        function init(obj, analysisTemplate, cellData)
            obj.cellData = cellData;
            init@sa_labs.analysis.core.Analysis(obj, analysisTemplate);
            obj.setEpochSource();
        end
        
        function setEpochSource(obj, ~)
            obj.extractor.epochStream = @(indices) obj.cellData.epochs(indices);
        end
        
        function collect(obj, dataStores)
            if nargin < 2
                dataStores = obj.nodeManager.dataStore;
            end
            arrayfun(@(ds) obj.resultManager.append(ds), dataStores);
        end
        
        function r = getResult(obj)
            r = obj.resultManager.dataStore;
        end
    end
    
    methods (Access = protected)
        
        function buildTree(obj)
            
            for pathIndex = 1 : obj.analysisTemplate.numberOfPaths()
                
                dataSet = sa_labs.analysis.entity.DataSet(1 : numel(obj.cellData.epochs), 'root');
                parameters = obj.analysisTemplate.getSplitParametersByPath(pathIndex);
                obj.buildBranches(obj.DEFAULT_ROOT_ID, dataSet, parameters);
            end
        end
        
        function p = getSplitParameters(obj)
            p = obj.analysisTemplate.getSplitParameters();
        end
        
        function nodes = getNodes(obj, parameter)
            nodes = obj.nodeManager.findNodesByName(parameter);
        end
        
        function updateEpochParameters(obj, nodes)
            
            if obj.nodeManager.isLeaf(nodes)
                obj.setEpochParameters(nodes);
            end
            keySet = obj.cellData.getEpochKeysetUnion([nodes.epochIndices]);

            if isempty(keySet)
                disp('[WARN] keyset is empty, cannot percolate up epoch parameters');
                return
            end
            obj.nodeManager.percolateUp([nodes.id], keySet, keySet);
        end
    end
    
    methods (Access = private)
        
        function buildBranches(obj, parentId, dataSet, params)
            splitBy = params{1};
            [epochValueMap, filter] = obj.cellData.getEpochValuesMap(splitBy, dataSet.epochIndices);
            splitValues = obj.analysisTemplate.validateSplitValues(splitBy, epochValueMap.keys);
            
            if isempty(splitValues) && length(params) > 1
                obj.nodeManager.removeNode(parentId);
            end
            
            for i = 1 : length(splitValues)
                splitValue = splitValues{i};
                epochIndices = epochValueMap(splitValue);
                
                if isempty(epochIndices)
                    continue
                end
                
                dataSet = sa_labs.analysis.entity.DataSet(epochIndices, filter, splitValue);
                if ~ isempty(dataSet)
                    id = obj.nodeManager.addNode(parentId, splitBy, splitValue, dataSet);
                end
                
                if length(params) > 1
                    obj.buildBranches(id, dataSet, params(2 : end));
                end
            end
        end
        
        function setEpochParameters(obj, nodes)
            for i = 1 : numel(nodes)
                [p, v] = obj.cellData.getUniqueParamValues(nodes(i).epochIndices);
                
                if isempty(p)
                    disp(['[WARN] no epoch parameter found for given node ' num2str(nodes(i).id)]);
                    continue;
                end
                nodes(i).setParameters(containers.Map(p, v));
            end
        end
    end
end