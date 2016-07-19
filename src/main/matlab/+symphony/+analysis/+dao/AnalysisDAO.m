classdef AnalysisDao < handle & mdepin.Bean
    
    properties
        repository
    end
    
    methods
        
        function obj = AnalysisDao(config)
            obj = obj@mdepin.Bean(config);
        end
        
        function fnames = findRawDataFiles(obj, date)
            date = obj.repository.dateFormat(date);
            path = [obj.repository.rawDataFolder filesep];
            info = dir([path date '*c*.h5']);
            fnames = arrayfun(@(d) [path d.name], info, 'UniformOutput', false);
        end
        
        function saveCellData(obj, data)
            dir = [obj.repository.analysisFolder filesep 'cellData' filesep];
            save([dir, data.savedFileName], 'data');
        end
        
        function projectFolder = createProject(obj, cellNames)
            today = obj.repository.dateFormat(now);
            projectFolder = [obj.repository.analysisFolder filesep 'Projects' filesep today '_temp'];
            symphony.analysis.util.file.overWrite(projectFolder);
            
            fid = fopen([projectFolder filesep 'cellNames.txt'], 'w');
            for i = 1 : length(cellNames)
                if ~ isempty(cellNames{i})
                    fprintf(fid, '%s\n', cellNames{i});
                end
            end
            fclose(fid);
        end
        
        function names = findCellDataNames(obj, date)
            date = obj.repository.dateFormat(date);
            info = dir([obj.repository.analysisFolder filesep 'cellData' filesep date '*c*.mat']);
            names = arrayfun(@(d) {d.name(1 : end-4)}, info);
        end
    end
    
end

