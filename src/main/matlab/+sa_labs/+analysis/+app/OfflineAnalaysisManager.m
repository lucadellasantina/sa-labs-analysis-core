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
        
        function cellData = parseSymphonyFiles(obj, date)
            files = obj.analysisDao.findRawDataFiles(date);
            
            if isempty(files)
                error('h5 file not found'); %TODO replace it with exception
            end
            
            for i = 1 : numel(files)
                obj.log.info(['parsing h5 file [ ' strrep(files{i}, '\', '/') ' ]' ]);
                parser = sa_labs.analysis.parser.getInstance(files{i});
                cellData = parser.parse().getResult();
                obj.analysisDao.saveCell(cellData);
                obj.log.info('saving data set ...' );
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

            obj.log.debug(['list of parsed files [ ' char(parsedFiles) ' ] unParsedfiles [ ' char(unParsedfiles) ' ]']);
        end
        
        function createProject(obj, project, preProcessors)
            import sa_labs.analysis.constants.*;
            
            if nargin < 3
                preProcessors = [];
            end
            
            obj.log.info(['creating project [ ' project.identifier ' ]' ]);
            dao = obj.analysisDao;
            [unParsedfiles, parsedFiles] = obj.getParsedAndUnParsedFiles(project);
            
            for i = 1 : numel(unParsedfiles)
                cellData = obj.parseSymphonyFiles(unParsedfiles{i});
                obj.preProcess(cellData, preProcessors);
                project.addCellData(cellData.savedFileName, cellData);
            end
            
            for i = 1 : numel(parsedFiles)
                cellData = dao.findCell(parsedFiles{i});
                project.addCellData(cellData.savedFileName,cellData);
            end
            dao.saveProject(project);
            obj.log.info(['Project created under location [ ' strrep(project.file, '\', '/') ' ]' ]);
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
        
        function preProcess(obj, cellData, functions, varargin)
            
            n = numel(functions);
            ip = inputParser;
            ip.addParameter('enabled', ones(1, n), @islogical);
            ip.parse(varargin{:});
            enabled = ip.Results.enabled;
            
            for i = 1 : n
                if enabled(i)
                    fun = functions{i};
                    obj.log.info(['pre processing data [ ' cellData.savedFileName ' ] for function [ ' char(fun) ' ] ']);
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

