classdef OfflineAnalaysisManager < handle & mdepin.Bean
    
    properties
        analysisDao
        preferenceDao
        log
    end
    
    methods
        
        function obj = OfflineAnalaysisManager(config)
            obj = obj@mdepin.Bean(config);
            obj.log = logging.getLogger(sa_labs.analysis.app.Constants.ANALYSIS_LOGGER);
        end
        
        function cellDataArray = parseSymphonyFiles(obj, date)
            import sa_labs.analysis.*;
            files = obj.analysisDao.findRawDataFiles(date);
            if isempty(files)
                error('h5 file not found'); %TODO replace it with exception
            end
            n = numel(files);
            cellDataArray = [];
            
            for i = 1 : n
                obj.log.info(['parsing ' num2str(i) '/' num2str(n) ' h5 file [ ' strrep(files{i}, '\', '/') ' ]' ]);
                parser = parser.getInstance(files{i});
                results = parser.parse().getResult();
                for j = 1 : numel(results)
                    obj.analysisDao.saveCell(results(j));
                    obj.log.info(['saving data set [ ' results(j).recordingLabel ' ]']);
                end
                cellDataArray = [results, cellDataArray]; %#ok
            end
        end
        
        function [unParsedfiles, parsedFiles] = getParsedAndUnParsedFiles(obj, project)
            
            dao = obj.analysisDao;
            cellNames = project.getCellDataNames();
            names = dao.findCellNames(cellNames);
            if isempty(names)
                names = {};
            end
            foundIndex = ismember(cellNames, names);
            parsedFiles = cellNames(foundIndex);
            unParsedfiles = cellNames(~ foundIndex);
            
            if isempty(parsedFiles)
                parsedFiles = {};
            end
            
            if isempty(unParsedfiles)
                unParsedfiles = {};
            end
            obj.log.debug(['list of parsed files [ ' char(parsedFiles) ' ] unParsedfiles [ ' char(unParsedfiles) ' ]']);
        end
        
        function project = createProject(obj, project, preProcessors)
            import sa_labs.analysis.constants.*;
            
            if nargin < 3
                preProcessors = [];
            end
            
            obj.log.info(['creating project [ ' project.identifier ' ]' ]);
            dao = obj.analysisDao;
            [unParsedfiles, parsedFiles] = obj.getParsedAndUnParsedFiles(project);
            
            for i = 1 : numel(unParsedfiles)
                cellDataArray = obj.parseSymphonyFiles(unParsedfiles{i});
                obj.preProcess(cellDataArray, preProcessors);
                parsedFiles = { parsedFiles{:}, cellDataArray.recordingLabel };
            end
            
            project.clearCellDataMap();            
            for i = 1 : numel(parsedFiles)
                cellData = dao.findCell(parsedFiles{i});
                project.addCellData(cellData.recordingLabel, cellData);
            end
            dao.saveProject(project);
            obj.log.info(['Project created under location [ ' strrep(project.file, '\', '/') ' ]' ]);
        end
        
        function project = initializeProject(obj, name)
            dao = obj.analysisDao;
            project = dao.findProjects(name);
            cellNames = project.getCellDataNames();
            for i = 1 : numel(cellNames)
                cellName = cellNames{i};
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
        
        function preProcess(obj, cellData, functions, varargin)
            
            n = numel(functions);
            ip = inputParser;
            ip.addParameter('enabled', ones(1, n), @islogical);
            ip.parse(varargin{:});
            enabled = ip.Results.enabled;
            
            for i = 1 : n
                if enabled(i)
                    fun = functions{i};
                    obj.log.info(['pre processing data [ ' cellData.recordingLabel ' ] for function [ ' char(fun) ' ] ']);
                    fun(cellData);
                end
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
                    analysis = core.OfflineAnalysis(protocol, cellData.recordingLabel);
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

