classdef AnalysisFolderDao < sa_labs.analysis.dao.AnalysisDao & mdepin.Bean
    
    properties
        repository
    end
    
    methods
        
        function obj = AnalysisFolderDao(config)
            obj = obj@mdepin.Bean(config);
            obj.repository = config.fileRepositorySettings;
        end
        
        function project = saveProject(obj, project)
            import sa_labs.analysis.*
            
            projectFile = [obj.repository.analysisFolder filesep  app.Constants.ANALYSIS_PROJECT_FOLDER ...
                filesep project.identifier filesep];
            
            util.file.overWrite(projectFile);
            projectStruct = struct();
            attributes = properties(project);
            
            for i = 1 : numel(attributes)
                attr = attributes{i};
                projectStruct.(attr) = project.(attr);
            end
            
            file = [projectFile 'project.json'];
            projectStruct.file = file;
            project.file = file;
            savejson('', projectStruct, file);
        end
        
        function projects = findProjects(obj, identifier)
            import sa_labs.analysis.*
            
            path = [obj.repository.analysisFolder filesep app.Constants.ANALYSIS_PROJECT_FOLDER filesep];
            info = dir(path);
            index = find(ismember({info.name}, identifier));
            
            if isempty(index)
                throw(app.Exceptions.NO_PROJECT.create());
            end
            
            projects = entity.AnalysisProject.empty(0, numel(index));
            for i = 1 : numel(index)
                structure = loadjson([path info(index(i)).name filesep 'project.json']);
                projects(i) = entity.AnalysisProject(structure);
            end
        end
        
        function fnames = findRawDataFiles(obj, date)
            import sa_labs.analysis.*
            
            if ~ ischar(date)
                date = obj.repository.dateFormat(date);
            end
            
            path = [obj.repository.rawDataFolder filesep];
            info = dir([path date '*.h5']);
            fnames = arrayfun(@(d) [path d.name], info, 'UniformOutput', false);
        end
        
        function saveCell(obj, cellData)
            import sa_labs.analysis.*
            
            dir = [obj.repository.analysisFolder filesep app.Constants.ANALYSIS_CELL_DATA_FOLDER filesep];
            if ~ exist(dir, 'dir')
                mkdir(dir);
            end
            
            if isa(cellData, 'sa_labs.analysis.entity.CellDataByAmp')
                CellDataByAmp = cellData;
                path = [dir CellDataByAmp.recordingLabel];
            else
                cellData.deviceType = '';
                path = [dir cellData.recordingLabel];
            end
            save(path, 'cellData');
            obj.repository.synchronizer.uploadCellData(path);
        end
        
        function names = findCellNames(obj, pattern)
            import sa_labs.analysis.*
            
            names = [];
            if isempty(pattern)
                return;
            end
            
            if ~ iscellstr(pattern)
                pattern = obj.repository.dateFormat(pattern);
                pattern = {[pattern '*c']};
            end
            isCellDataByAmp = all(cellfun(@(p) any(strfind(p, 'Amp')), pattern));
            
            for i = 1 : numel(pattern)
                p = pattern{i};
                info = dir([obj.repository.analysisFolder filesep app.Constants.ANALYSIS_CELL_DATA_FOLDER filesep char(p) '*.mat']);
                fnames = arrayfun(@(d) {d.name(1 : end-4)}, info);
                names = [fnames; names]; %#ok
            end
            
            if isempty(names)
                names = obj.repository.synchronizer.findCellNames(pattern);
            end
            
            % Filter for cell data without amp extension
            if ~ isempty(names) && ~ isCellDataByAmp
                indices = cellfun(@(name) any(strfind(name, '_Amp')), names);
                names = names(~indices);
            end
        end
        
        function cellData = findCell(obj, cellName)
            import sa_labs.analysis.*
            
            obj.repository.synchronizer.downloadCellData(cellName);
            
            pathFun = @(cellName) [obj.repository.analysisFolder filesep app.Constants.ANALYSIS_CELL_DATA_FOLDER filesep cellName '.mat'];
            result = load(pathFun(cellName));
            cellData = result.cellData;
            
            if isa(cellData, 'sa_labs.analysis.entity.CellDataByAmp')
                cellDataByAmp = cellData;
                result = load(pathFun(cellDataByAmp.cellDataRecordingLabel));
                cellData = result.cellData;
                cellDataByAmp.updateCellDataForTransientProperties(cellData);
            end
        end
        
        function saveAnalysisResults(obj, resultId, result, protocol) %#ok
            import sa_labs.analysis.*
            
            dir = [obj.repository.analysisFolder filesep app.Constants.ANALYSIS_TREES_FOLDER filesep];
            if ~ exist(dir, 'dir')
                mkdir(dir);
            end
            save([dir resultId], 'result');
            savejson('', protocol, [dir resultId '.json']);
        end
        
        function names = findAnalysisResultNames(obj, pattern)
            import sa_labs.analysis.*
            names = [];
            if isempty(pattern)
                return;
            end
            if ~ iscellstr(pattern)
                pattern = obj.repository.dateFormat(pattern);
            end
            
            for i = 1 : numel(pattern)
                p = pattern{i};
                info = dir([obj.repository.analysisFolder filesep app.Constants.ANALYSIS_TREES_FOLDER filesep '*' char(p) '*.mat']);
                fnames = arrayfun(@(d) {d.name(1 : end-4)}, info);
                names = [fnames; names]; %#ok
            end
        end
        
        function result = findAnalysisResult(obj, resultId)
            import sa_labs.analysis.*
            path = [obj.repository.analysisFolder filesep app.Constants.ANALYSIS_TREE_FOLDER filesep resultId];
            r = load(path);
            result = r.result;
        end
        
        function saveCellDataFilter(obj, filterName, filterTable) %#ok
            import sa_labs.analysis.*
            dir = [obj.repository.analysisFolder filesep app.Constants.ANALYSIS_FILTER_FOLDER filesep app.Constants.ANALYSIS_CELL_DATA_FOLDER filesep];
            if ~ exist(dir, 'dir')
                mkdir(dir);
            end
            save([dir filterName], 'filterTable');
        end
        
        function filterMap = getCellDataFilters(obj)
            import sa_labs.analysis.*
            
            filterMap = [];
            directory = [obj.repository.analysisFolder filesep app.Constants.ANALYSIS_FILTER_FOLDER filesep app.Constants.ANALYSIS_CELL_DATA_FOLDER filesep];
            if ~ exist(directory, 'dir')
                return;
            end
            info = dir([directory '*.mat']);
            fnames = arrayfun(@(d) {d.name(1 : end-4)}, info);
            filterMap = containers.Map();
            for name = each(fnames)
                filter = load([directory  name '.mat']);
                filterMap(name) = filter.filterTable;
            end
        end
    end
    
end

