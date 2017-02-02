classdef AnalysisDao < handle
    
    methods(Abstract)
        saveProject(obj, project)
        findProjects(obj, identifier)
        findRawDataFiles(obj, regexp)
        saveCell(obj, cellData)
        findCell(obj, cellName)
        findCellNames(obj, regexp)
        saveAnalysisResult(obj, cellName, protocol, result)
        findAnalysisResult(obj, regexp)
    end
    
end

