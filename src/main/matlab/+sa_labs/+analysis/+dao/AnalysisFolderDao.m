classdef AnalysisFolderDao < sa_labs.analysis.dao.AnalysisDao & mdepin.Bean
    
    properties
        repository
    end
    
    methods
        
        function obj = AnalysisFolderDao(config)
            obj = obj@mdepin.Bean(config);
        end
        
        function project = saveProject(obj, project)
            
            projectFile = [obj.repository.analysisFolder filesep 'Projects'...
                filesep project.identifier filesep];
            
            sa_labs.analysis.util.file.overWrite(projectFile);
            projectStruct = struct();
            attributes = properties(project);
            
            for i = 1 : numel(attributes)
                attr = attributes{i};
                projectStruct.(attr) = project.(attr);
            end
            file = [projectFile 'project.yaml'];
            yaml.WriteYaml(file, projectStruct, 1);
            project.file = file;
        end
        
        function projects = findProjects(obj, identifier)
            import sa_labs.analysis.*
            
            path = [obj.repository.analysisFolder filesep 'Projects' filesep];
            info = dir(path);
            index = find(ismember({info.name}, identifier));
            
            if isempty(index)
                throw(app.Exceptions.NO_PROJECT.create());
            end
            
            projects = entity.AnalysisProject.empty(0, numel(index));
            for i = 1 : numel(index)
                projects(i) = entity.AnalysisProject(yaml.ReadYaml([path info(index(i)).name filesep 'project.yaml']));
            end
            
        end
        
        function fnames = findRawDataFiles(obj, date)
            
            if ~ ischar(date)
                try
                    date = obj.repository.dateFormat(date);
                catch exception
                    disp(exception.message);
                    date = [];
                end
            end
            path = [obj.repository.rawDataFolder filesep];
            info = dir([path date '*.h5']);
            fnames = arrayfun(@(d) [path d.name], info, 'UniformOutput', false);
        end
        
        function saveCell(obj, cellData)
            dir = [obj.repository.analysisFolder filesep 'cellData' filesep];
            if ~ exist(dir, 'dir')
                mkdir(dir);
            end
            save([dir cellData.savedFileName], 'cellData');
        end
        
        function names = findCellNames(obj, date)
            names = [];
            if isempty(date)
                return; 
            end
            date = obj.repository.dateFormat(date);
            info = dir([obj.repository.analysisFolder filesep 'cellData' filesep date '*c*.mat']);
            names = arrayfun(@(d) {d.name(1 : end-4)}, info);
        end
        
        function cellData = findCell(obj, cellName)
            path = [obj.repository.analysisFolder filesep 'cellData' filesep cellName];
            result = load(path);
            cellData = result.cellData;
        end
        
        function saveAnalysisResult(obj, cellName, protocol, result)
        end
        
        function result = findAnalysisResult(obj, regexp)
            result = [];
        end
    end
    
end

