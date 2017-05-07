classdef OfflineAnalaysisManager < handle & mdepin.Bean
    
    properties
        analysisDao
        parserFactory
        log
    end
    
    methods
        
        function obj = OfflineAnalaysisManager(config)
            obj = obj@mdepin.Bean(config);
            obj.log = logging.getLogger(sa_labs.analysis.app.Constants.ANALYSIS_LOGGER);
        end
        
        function cellDataArray = parseSymphonyFiles(obj, pattern)

            % parseSymphonyFiles - parses h5 files from raw data folder based on 
            % input pattern and returns the cell data as array
            %
            % If the input pattern is not valid (or)
            % no files were found in the raw data folder then throws
            % no raw data found exception. 
            %
            % In case of that excpetion, make sure to check the rawDataFolder
            % whether it has the valid h5 file. If not copy that from the 
            % server and trigger the parsing again
            % 
            % On successful parsing the cell data will be saved in the 
            % analysis folder
            %
            % usage : obj.parseSymphonyFiles('20170505A')
            %         obj.parseSymphonyFiles('201705')
            %         obj.parseSymphonyFiles(date)  


            import sa_labs.analysis.*;
            dao = obj.analysisDao;
            files = dao.findRawDataFiles(pattern);

            if isempty(files)
                 throw(app.Exceptions.NO_RAW_DATA_FOUND.create('message', char(pattern)));
            end
            n = numel(files);
            cellDataArray = [];
            
            for i = 1 : n
                obj.log.info(['parsing ' num2str(i) '/' num2str(n) ' h5 file [ ' strrep(files{i}, '\', '/') ' ]' ]);
                parser =  obj.parserFactory.getInstance(files{i});
                results = parser.parse().getResult();

                for result = each(results)
                    dao.saveCell(result);
                    obj.log.info(['saving data set [ ' result.recordingLabel ' ]']);
                end
                cellDataArray = [results, cellDataArray]; %#ok
            end
        end
        
        function [parsedExperiments, unParsedExperiments] = getParsedAndUnParsedFiles(obj, experiments)
            
            % A simple utility function to get parsed and un-parsed files 
            % by experiment name (i.e date)

            index = cellfun(@(e) isempty(obj.analysisDao.findCellNames(e)), experiments);
            unParsedExperiments = experiments(index);
            parsedExperiments = experiments(~ index);
            
            obj.log.info(['list of parsed files [ ' strjoin(parsedExperiments) ' ] unParsed files [ ' strjoin(unParsedExperiments) ' ]']);
        end
        
        function obj = createProject(obj, project, preProcessors)

            % createProject - creates a new analysis project from project.experimentList.
            % If its already present, then it simply loads the project.
            %
            % returns the manager obj and cell data injected project instance 
            %
            % While creating new project, it checks whether it has 
            % the required cell data files. If not it attempts to parse the
            % raw data file (h5) and generates the cell data. For the existing celldata
            % it simply finds the serialized object from the dao and saves
            % to the project file
            %
            % usage : obj.createProject(analysisProject)

            import sa_labs.analysis.constants.*;
            
            if nargin < 3
                preProcessors = [];
            end
            
            obj.log.info(['creating project [ ' project.identifier ' ]' ]);
            dao = obj.analysisDao;
            [unParsedExperiments, parsedExperiments] = obj.getParsedAndUnParsedFiles(project.experimentList);
            
            for unParsedExp = each(unParsedExperiments)
                obj.parseSymphonyFiles(unParsedExp);
                parsedExperiments{end + 1} = unParsedExp; %#ok <AGROW>
            end
            project.clearCellData();

            for exp = each(parsedExperiments)
                for cellData = dao.findCell(exp)
                    project.addCellData(cellData.recordingLabel, cellData);
                    file = dao.findRawDataFiles(cellData.h5File);
                    
                    if isempty(file)
                        throw(app.Exceptions.NO_RAW_DATA_FOUND.create('message', char(file)));
                    end
                end
            end

            dao.saveProject(project);
            obj.log.info(['Project created under location [ ' strrep(project.file, '\', '/') ' ]' ]);
            arrayfun(@(d) obj.preProcess(d, preProcessors), project.getCellDataArray());
        end
        
        function project = initializeProject(obj, name)
            
            dao = obj.analysisDao;  
            project = dao.findProjects(name);

            for cellName = each(project.cellDataList)
                cellData = dao.findCell(cellName);
                project.addCellData(cellName, cellData);
                file = dao.findRawDataFiles(cellData.h5File);
                
                if isempty(file)
                    throw(app.Exceptions.NO_RAW_DATA_FOUND.create('message', char(file)));
                end
            end
            
            cellfun(@(id) project.addResult(id, dao.findAnalysisResult(id), project.analysisResultNames));
            obj.log.info(['project [ ' project.identifier ' ] initialized ']);
        end
        
        function preProcess(obj, cellData, functions, varargin)
            
            n = numel(functions);
            ip = inputParser;
            ip.addParameter('enabled', ones(1, n), @islogical);
            ip.parse(varargin{:});
            enabled = ip.Results.enabled;
            
            for data = each(cellData)

                for fun = each(functions(enabled))
                    obj.log.info(['pre processing data [ ' cellData.recordingLabel ' ] for function [ ' char(fun) ' ] ']);
                    fun(cellData);
                end
                obj.analysisDao.saveCell(data);
            end
        end
        
        function project = buildAnalysis(obj, projectName, presets)
            import sa_labs.analysis.*;
            
            project = obj.initializeProject(projectName);
            
            for cellData = each(project.getCellDataArray())

                for preset = each(presets)
                    protocol = core.AnalysisProtocol(preset);
                    analysis = core.OfflineAnalysis(protocol, cellData.recordingLabel);
                    analysis.setEpochSource(cellData);
                    analysis.service();
                    result = analysis.getResult();
                    obj.analysisDao.saveAnalysisResults(analysis.identifier, result, protocol);
                    project.addResult(analysis.identifier, result);
                end
            end
            obj.analysisDao.saveProject(project);
        end
        
        % TODO optimize

        function builder = getFeatureBuilder(obj, projectName, results)
            import sa_labs.analysis.*;
            
            if nargin < 3
                project = obj.initializeProject(projectName);
                results =  project.getAllresult();
            end
            builder = core.factory.createFeatureBuilder('project', projectName,...
                'data', results);
        end
        
        function featureBuilder = applyAnalysis(obj, featureBuilder, featureGroup, functions)
            import sa_labs.analysis.*;
            
            groups = featureBuilder.findFeatureGroup('analysis');
            project = featureBuilder.findFeatureGroup('project').splitValue;
            dao = obj.analysisDao;
            results = tree.empty(0, numel(groups));
            index = 1;
            for group = groups
                resultIdArray = strsplit(group.splitValue, '-');
                cellData = dao.findCell(resultIdArray{end});
                
                protocol = group.parameters.analysisProtocol;
                analysis = core.OfflineAnalysis(protocol, cellData.recordingLabel);
                analysis.setEpochSource(cellData);
                analysis.featureBuilder.dataStore = dao.findAnalysisResult(group.splitValue);
                
                analysis.addFeaturesToGroup(featureGroup, functions);
                
                result = analysis.getResult();
                dao.saveAnalysisResults(analysis.identifier, result, protocol);
                results(index) = result;
                index = index + 1;
            end
            featureBuilder = core.factory.createFeatureBuilder('project', project,...
                'data', results);
        end
    end
end

