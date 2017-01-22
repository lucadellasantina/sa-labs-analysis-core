classdef AnalysisDao < handle
    
    methods(Abstract)
        findRawDataFiles(obj, regexp)
        saveCell(obj, cellData)
        findCellNames(obj, regexp)
        findCell(obj, cellName)

        createProject(obj, project)
        saveAnalysisResult(obj, cellName, protocol, result)
        findAnalysisResult(obj, regexp)
    end
    
end

