classdef OfflineAnalysis < sa_labs.analysis.core.Analysis
    
    properties(Access = private)
        cellData
        resultManager
    end
    
    properties(Constant)
        DEFAULT_ROOT_ID = 1;
    end
    
    methods
        
        function obj = OfflineAnalysis(name, cellData)
            
            obj@sa_labs.analysis.core.Analysis();
            obj.cellData = cellData;
            obj.resultManager = sa_labs.analysis.core.NodeManager();
            obj.resultManager.setRootName(name);
        end
        
        function setEpochStream(obj)
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
    
    methods(Access = protected)
        
        function buildTree(obj)
            
            % loop throug the parameters list of individual path
            % and construct analysis tree
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
    end
    
    methods(Access = private)
        
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
    end
end