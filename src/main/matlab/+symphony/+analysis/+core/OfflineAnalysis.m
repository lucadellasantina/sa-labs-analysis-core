classdef OfflineAnalysis < symphony.analysis.core.Analysis
    
    properties(Access = private)
        cellData
        level = 0
        maximumLevels
    end
    
    methods
        
        function obj = OfflineAnalysis(name, cellData)
            obj@symphony.analysis.core.Analysis(name);
            obj.cellData = cellData;
        end
        
    end
    
    methods(Access = protected)
        
        function buildTree(obj)
            dataSetMap = obj.cellData.savedDataSets;
            values = dataSetMap.keys;
            
            splitParameters = obj.analysisTemplate.splitParameters;
            splitByDataSet = splitParameters{1};
            otherParameters = splitParameters(2:end);
            obj.maximumLevels = numel(splitParameters);
            
            for i = 1 : numel(values)
                values = obj.analysisTemplate.validateLevel(obj.getNextLevel(), splitByDataSet, values);
                
                if isempty(values)
                    throw(symphony.analysis.app.Exceptions.NO_DATA_SET_FOUND.create());
                end
                splitValue = values{i};
                dataSet = dataSetMap(splitValue);
                id = obj.nodeManager.addNode(1, splitByDataSet, splitValue, dataSet);
                obj.buildBranches(id, dataSet, otherParameters);
            end
        end
        
        function buildBranches(obj, parentId, dataSet, params)
            
            splitBy = params{1};
            [epochValueMap, filter] = obj.cellData.getEpochValuesMap(splitBy, dataSet.epochIndices);
            splitValues = obj.analysisTemplate.validateLevel(obj.getNextLevel(), splitBy, epochValueMap.keys);
            
            for i = 1 : length(splitValues)
                splitValue = splitValues{i};
                epochIndices = epochValueMap(splitValue);
                
                if isempty(epochIndices)
                    continue
                end
                dataSet = symphony.analysis.entity.DataSet(epochIndices, filter, splitValue);
                id = obj.nodeManager.addNode(parentId, splitBy, splitValue, dataSet);
                
                if length(params) > 1
                    obj.buildBranches(id, dataSet, params(2 : end));
                end
            end
        end
        
        function setEpochIterator(obj)
            obj.extractor.epochIterator = @(index) obj.cellData.epochs(index);
        end
    end
    
    methods(Access = private)
        
        function level = getNextLevel(obj)
            obj.level = obj.level + 1;
            
            level = mod(obj.level, obj.maximumLevels);
            if level == 0
                level = obj.maximumLevels;
            end
        end
    end
end