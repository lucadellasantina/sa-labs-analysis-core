classdef AnalysisDao < handle
    
    properties
        repository
    end
    
    methods
        
        function saveCellData(obj, data)
             dir = [obj.repository.analysisFolder 'cellData' filesep];
             save([dir, data.savedFileName], 'data');
        end
        
        function projectFolder = createProject(obj, cellNames)
            projectFolder = [obj.repository.analysisFolder 'Projects' filesep date '_temp'];
            symphony.analysis.util.file.overWrite(projectFolder);
            
            fid = fopen([projectFolder filesep 'cellNames.txt'], 'w');
            for i = 1 : length(cellNames)
                if ~ isempty(cellNames{i})
                    fprintf(fid, '%s\n', cellNames{i});
                end
            end
            fclose(fid);
        end
      
        function names = findCellDataNames(date)
            info = dir([obj.repository.analysisFolder 'cellData' filesep date '*c*.mat']);
            names = arrayfun(@(d) d.name(1 : end-2), info);
        end
    end
    
end

