classdef AnalysisFolderDao < sa_labs.analysis.dao.AnalysisDao & mdepin.Bean
    
    properties
        repository
    end
    
    methods
        
        function obj = AnalysisFolderDao(config)
            obj = obj@mdepin.Bean(config);
        end
        
        function fnames = findRawDataFiles(obj, date)
            
            try
                date = obj.repository.dateFormat(date);
                
            catch exception
                disp(exception.message);
                date = [];
            end
            path = [obj.repository.rawDataFolder filesep];
            info = dir([path date '*.h5']);
            fnames = arrayfun(@(d) [path d.name], info, 'UniformOutput', false);
        end
        
        function saveCell(obj, cellData)
            dir = [obj.repository.analysisFolder filesep 'cellData' filesep];
            save([dir cellData.savedFileName], 'cellData');
        end
        
        function names = findCellNames(obj, date)
            date = obj.repository.dateFormat(date);
            info = dir([obj.repository.analysisFolder filesep 'cellData' filesep date '*c*.mat']);
            names = arrayfun(@(d) {d.name(1 : end-4)}, info);
        end
        
        function cellData = findCell(obj, cellName)
            path = [obj.repository.analysisFolder filesep 'cellData' filesep cellName];
            result = load(path);
            cellData = result.cellData;
        end
        
        function projectFolder = createProject(obj, project)
            cellNames = project.experimentFiles;
            today = obj.repository.dateFormat(now);
            
            projectFolder = [obj.repository.analysisFolder filesep 'Projects' filesep today '_temp'];
            sa_labs.analysis.util.file.overWrite(projectFolder);
            
            fid = fopen([projectFolder filesep 'cellNames.txt'], 'w');
            for i = 1 : length(cellNames)
                if ~ isempty(cellNames{i})
                    fprintf(fid, '%s\n', cellNames{i});
                end
            end
            fclose(fid);
        end
        
        function saveAnalysisResult(obj, cellName, protocol, result)
        end

        function result = findAnalysisResult(obj, regexp)
            result = [];
        end
    end
    
end

