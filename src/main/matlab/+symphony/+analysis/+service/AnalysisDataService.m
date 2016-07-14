classdef AnalysisDataService < handle
    
    properties
        symphonyParser
        analysisDao
    end
    
    methods
        
        function data = parseSymphonyFiles(obj, date)
            data = obj.symphonyParser.parse(date);
            obj.analysisDao.saveCellData(data);
        end
        
        function saveDataSets(obj, cellName)
            obj.analysisDao.saveCellData(dataSet);
        end
        
        function updateDataSets(obj, cellName)
        end
        
        function tf = isCellDataExist(obj, date)
            names = obj.analysisDao.findCellDataNames(date);
            tf = isempty(names);
        end
        
        function tf = isDataSetExist(obj, dataSetName)
            names = obj.analysisDao.findCellDataSetNames(dataSetName);
            tf = isempty(names);
        end
    end
    
end

