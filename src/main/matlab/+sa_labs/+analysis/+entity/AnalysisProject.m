classdef AnalysisProject < handle & matlab.mixin.CustomDisplay
    
    properties
        identifier
        cellDataNames
        description
        date
        performedBy
        file
    end
    
    properties(Access = private)
        cellDataMap
    end
    
    methods
        function obj = AnalysisProject(structure)
            obj.cellDataMap = containers.Map();
            
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
    end
end