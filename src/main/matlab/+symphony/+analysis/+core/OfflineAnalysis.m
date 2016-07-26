classdef OfflineAnalysis < symphony.analysis.core.Analysis
    
    properties
        cellData
        spiltParameters
    end
    
    properties(Access = private)
        requestCache
    end
    
    methods
        
        function obj = OfflineAnalysis(request)
            obj@symphony.analysis.core.Analysis(request.builderContext);
            obj.requestCache = request;
            obj.cellData = request.cellData;
            obj.spiltParameters = request.splitParameters;
        end
        
        function buildTree(obj)
           obj.buildByDataSet();
        end
        
        function createFeature(obj, builders, splitParameters)
            for i = 1 : numel(builders)
                builder = builders(i);
                builder.epochHandler = @(device, index) obj.cellData.epochs(index).response(device); 
                builder.build(splitParameters);
            end
        end
        
    end
    
    methods(Access = protected)
        
        function buildByDataSet(obj)
            names = obj.cellData.dataSetMap.keys;
            
            for i = 1 : numel(names)
                epochIndices = obj.cellData.dataSetMap(names(i));
                id = nodeManager.addNode(1, 'DataSet', names(i), epochIndices);
                obj.buildByParameters(id, epochIndices);
            end
        end
        
        function buildByParameters(obj, parentId, epochIndices, params)
            
            if nargin < 5
                params = obj.spiltParameters;
            end
            [epochValueMap, description] = obj.cellData.getEpochValuesMap(params{1}, epochIndices);
            uniqueValues = epochValueMap.keys;
            
            for i = 1 : length(uniqueValues)
                value = uniqueValues(i);
                epochIndices = epochValueMap(value);
                
                if isempty(epochIndices)
                    continue
                end
                id = nodeManager.addNode(parentId, description, value, epochIndices);
                
                if length(params) > 1
                    obj.buildByParameters(id, epochIndices, params(2 : end));
                end
            end
        end
        
    end
end