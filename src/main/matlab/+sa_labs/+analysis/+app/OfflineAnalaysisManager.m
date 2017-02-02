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
            project = dao.findProject(name);
            
            for i = 1 : numel(project.cellNames)
                name = dao.findRawDataFiles(project.cellNames{i});
                
                if isempty(name)
                    % TODO copy raw data files from server to local
                end
            end
        end
        
        function cellData = preProcess(obj, cellData, functions)
            
            for i = 1 : numel(functions)
                fun = functions{i};
                cellData = fun(cellData);
            end
            obj.analysisDao.saveCellData(cellData);
        end
        
        
        function doOfflineAnalysis(obj, request)
            import sa_labs.analysis.*;
            
            analysisProject = obj.initializeProject(request.projectName);
            protocols = request.getAnalysisProtocols();
            cellDataList = analysisProject.getCellDataList();
            
            for i = 1 : numel(cellDataList)
                cellData = cellDataList{i};
                
                for j = 1 : numel(protocols)
                    protocol = protocols(j);
                    analysis = core.OfflineAnalysis(protocol, cellData.recordingLabel);
                    analysis.setEpochSource(cellData);
                    analysis.service();
                    obj.analysisDao.saveAnalysisResults(cellName, protocol, analysis.getResult());
                end
            end
        end
        
    end
end

