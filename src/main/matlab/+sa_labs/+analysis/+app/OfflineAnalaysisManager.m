classdef OfflineAnalaysisManager < handle & mdepin.Bean
    
    properties
        analysisDao
        preferenceDao
    end
    
    methods
        
        function obj = OfflineAnalaysisManager(config)
            obj = obj@mdepin.Bean(config);
        end
        
        function cellData = parseSymphonyFiles(obj, date)
            files = obj.analysisDao.findRawDataFiles(date);
            
            if isempty(files)
                error('h5 file not found'); %TODO replace it with exception
            end
            
            for i = 1 : numel(files)
                parser = sa_labs.analysis.parser.getInstance(files{i});
                cellData = parser.parse().getResult();
                obj.analysisDao.saveCell(cellData);
            end
        end
        
        function createProject(obj, project)
            import sa_labs.analysis.constants.*;
            
            dao = obj.analysisDao;
            names = dao.findCellNames(project.cellDataNames);
            
            if isempty(names)
                cellData = obj.parseSymphonyFiles(project.experimentDate);
            end
            project.addCellData(cellData.savedFileName, cellData);
            dao.saveProject(project);
        end
        
        function project = initializeProject(obj, name)
            dao = obj.analysisDao;
            project = dao.findProjects(name);
            
            for i = 1 : numel(project.cellDataNames)
                cellName = project.cellDataNames{i};
                cellData = dao.findCell(cellName);
                project.addCellData(cellName, cellData);
                file = dao.findRawDataFiles(cellData.experimentDate);
                
                if isempty(file)
                    % TODO check and synchronize from server
                    error('h5 file not found in the rawDataFolder')
                end
            end
            
            for i = 1 : numel(project.analysisResultNames)
                resultId = project.analysisResultNames{i};
                result = dao.findAnalysisResult(resultId);
                project.addResult(resultId, result);
            end
        end
        
        function preProcess(obj, cellData, functions)
            
            for i = 1 : numel(functions)
                fun = functions{i};
                fun(cellData);
            end
            obj.analysisDao.saveCell(cellData);
        end
        
        
        function project = doAnalysis(obj, projectName, protocols)
            import sa_labs.analysis.*;
            
            project = obj.initializeProject(projectName);
            cellDataList = project.getCellDataList();
            
            for i = 1 : numel(cellDataList)
                cellData = cellDataList{i};
                
                for j = 1 : numel(protocols)
                    protocol = protocols(j);
                    analysis = core.OfflineAnalysis(protocol, cellData.savedFileName);
                    analysis.setEpochSource(cellData);
                    analysis.service();
                    result = analysis.getResult();
                    obj.analysisDao.saveAnalysisResults(analysis.identifier, result, protocol);
                    project.addResult(analysis.identifier, result);
                end
                obj.analysisDao.saveProject(project);
            end
        end
    end
end

