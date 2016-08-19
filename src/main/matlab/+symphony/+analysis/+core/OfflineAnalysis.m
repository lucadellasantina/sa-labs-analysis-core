classdef OfflineAnalysis < symphony.analysis.core.Analysis
    
    properties
        cellData
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
            level = 1;
            
            splitByDataSet = obj.analysisTemplate.splitParameters{1};
            otherParameters = obj.analysisTemplate.splitParameters(2:end);
            
            for i = 1 : numel(values)
                values = obj.analysisTemplate.validateLevel(level, splitByDataSet, values);
                
                if isempty(values)
                    throw(symphony.analysis.app.Exceptions.NO_DATA_SET_FOUND.create());
                end
                splitValue = values{i};
                dataSet = dataSetMap(splitValue);
                id = obj.nodeManager.addNode(1, splitByDataSet, splitValue, dataSet);
                obj.buildBranches(id, level + 1, dataSet, otherParameters);
            end
        end
        
        function buildBranches(obj, level, parentId, dataSet, params)
            
            splitBy = params{1};
            [epochValueMap, filter] = obj.cellData.getEpochValuesMap(splitBy, dataSet.epochIndices);
            splitValues = obj.analysisTemplate.validateLevel(level, splitBy, epochValueMap.keys);
            
            for i = 1 : length(splitValues)
                splitValue = splitValues{i};
                epochIndices = epochValueMap(splitValue);
                
                if isempty(epochIndices)
                    continue
                end
                dataSet = symphony.analysis.entity.DataSet(epochIndices, filter, splitValue);
                id = obj.nodeManager.addNode(parentId, splitBy, splitValue, dataSet);
                
                if length(params) > 1
                    obj.buildBranches(id, level + 1, dataSet, params(2 : end));
                end
            end
        end
        
        function setEpochIterator(obj)
            obj.extractor.epochIterator = @(index) obj.cellData.epochs(index);
        end

    end
end