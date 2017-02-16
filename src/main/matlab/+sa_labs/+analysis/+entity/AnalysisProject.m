classdef AnalysisProject < handle & matlab.mixin.CustomDisplay
    
    properties
        identifier
        cellDataNames
        analysisResultNames
        description
        analysisDate
        experimentDate
        performedBy
        file
    end
    
    properties(Access = private)
        cellDataMap
        resultMap
    end
    
    methods
        function obj = AnalysisProject(structure)
            obj.cellDataMap = containers.Map();
            obj.resultMap = containers.Map();

            if nargin < 1
                return
            end
            attributes = fields(structure);
            for i = 1 : numel(attributes)
                attr = attributes{i};
                obj.(attr) = structure.(attr);
            end
        end
        
        function addCellData(obj, cellName, cellData)
            if ~ any(ismember(obj.cellDataNames, cellName))
                obj.cellDataNames{end + 1} = cellName;
            end
            obj.cellDataMap(cellName) = cellData;
        end
        
        function c = getCellData(obj, cellName)
            c = obj.cellDataMap(cellName);
        end

        function list = getCellDataList(obj)
            list = obj.cellDataMap.values;
        end

        function addResult(obj, resultId, analysisResult)
            if ~ isKey(obj.resultMap, resultId)
                obj.analysisResultNames{end + 1} = resultId;
            end
            obj.resultMap(resultId) = analysisResult;
        end
        
        function c = getResult(obj, resultId)
            c = obj.resultMap(resultId);
        end

        function list = getAllresult(obj)
            list = obj.resultMap.values;
            list = [list{:}];
        end
    end
end