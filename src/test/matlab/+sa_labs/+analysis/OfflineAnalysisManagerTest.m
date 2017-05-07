classdef OfflineAnalysisManagerTest < matlab.unittest.TestCase
    
    properties
        beanFactory
        manager
        parserFactoryMock
    end

    properties (Constant)
        DATE_FORMAT = 'yyyymmdd'
    end
    
    methods (TestClassSetup)
        
        function initContext(obj)
            import sa_labs.analysis.*;
            obj.beanFactory = mdepin.getBeanFactory(which('TestContext.m'));
            obj.manager = obj.beanFactory.getBean('offlineAnalaysisManager');
        end

        function setUpParserFactory(obj)

            % not mocking the cell data since arrays of mock wont work
            cellData(1) = sa_labs.analysis.entity.CellData();
            cellData(1).recordingLabel = 'one';

            cellData(2) = sa_labs.analysis.entity.CellData();
            cellData(2).recordingLabel = 'two';

            parserMock = Mock();
            parserFactory = Mock();
            parserFactory.when.getInstance(AnyArgs()).thenReturn(parserMock).times(100);
            parserMock.when.parse(AnyArgs()).thenReturn(cellData).times(100);

            obj.parserFactoryMock = parserFactory;
        end
    end
    
    methods(Test)
        
        function testParseSymphonyFiles(obj)
            dao = Mock();
            dao.when.findRawDataFiles(AnyArgs()).thenReturn({'20170505A.h5'})...
                                                .thenReturn({'20170504A.h5', '20170505A.h5'})...
                                                    .thenReturn([]);  % for exception scenario

            % Inject the mocks
            obj.manager.analysisDao = dao;    
            obj.manager.parserFactory = obj.parserFactoryMock;
            
            actual = obj.manager.parseSymphonyFiles('20170505A');
            
            obj.verifyLength(actual, 2);
            obj.verifyEmpty(setdiff({actual.recordingLabel}, {'one', 'two'}));
            
            actual = obj.manager.parseSymphonyFiles('201705');
            obj.verifyLength(actual, 4);
            obj.verifyEmpty(setdiff({actual.recordingLabel},  {'one', 'two'}));

            handle = @() obj.manager.parseSymphonyFiles('unknown');
            obj.verifyError(handle, sa_labs.analysis.app.Exceptions.NO_RAW_DATA_FOUND.msgId);
        end

        function testGetParsedAndUnParsedFiles(obj)
            dao = Mock();
            dao.when.findCellNames(AnyArgs()).thenReturn({'20170504Ac1', '20170504Ac2', '20170504Ac3'})...
                                                .thenReturn('20170505Ac1')...
                                                .thenReturn([])...
                                                .thenReturn({'20170507Ac1', '20170505Ac2'});
            experiments = {'20170504A', '20170505A', '20170506A', '20170507A'};

            % Few parsed and one un parsed file
            obj.manager.analysisDao = dao; % Inject the mock in dao          
            [actualParsed, actualUnParsed] = obj.manager.getParsedAndUnParsedFiles(experiments);
            obj.verifyEqual(actualParsed, experiments([1, 2, 4]));
            obj.verifyEqual(actualUnParsed, experiments(3));

            % no parsed files        
            dao = Mock();
            dao.when.findCellNames(AnyArgs()).thenReturn([]).times(4);
            obj.manager.analysisDao = dao;     
            [actualParsed, actualUnParsed] = obj.manager.getParsedAndUnParsedFiles(experiments);
            obj.verifyEmpty(actualParsed);
            obj.verifyEqual(actualUnParsed, experiments);

            % all files are parsed
            dao = Mock();
            dao.when.findCellNames(AnyArgs()).thenReturn({'20170504Ac1', '20170504Ac2', '20170504Ac3'})...
                                                .thenReturn('20170505Ac1')...
                                                .thenReturn('20170506Ac1')...
                                                .thenReturn({'20170507Ac1', '20170505Ac2'});

            obj.manager.analysisDao = dao;
            [actualParsed, actualUnParsed] = obj.manager.getParsedAndUnParsedFiles(experiments);
            obj.verifyEqual(actualParsed, experiments);
            obj.verifyEmpty(actualUnParsed);
        end 

        function testCreateProject(obj)

            function cellDatas = mockedCellData(file, labels)
                n = numel(labels);
                cellDatas = sa_labs.analysis.entity.CellData.empty(0, n);
                for i = 1 : n
                    cellDatas(i) = sa_labs.analysis.entity.CellData();
                    cellDatas(i).h5File = file;
                    cellDatas(i).recordingLabel = labels{i};
                end
            end

            dao = Mock();
            dao.when.findRawDataFiles(AnyArgs()).thenReturn({'20170505A.h5'})... % coz of parse symphony files
                                                .thenReturn({'20170504A.h5'}).times(3)... % coz of create project loop for parsed file
                                                .thenReturn({'20170505A.h5'}).times(2); % coz of create project loop for un-parsed file

            dao.when.findCellNames(AnyArgs()).thenReturn({'20170504Ac1', '20170504Ac2', '20170504Ac3'})...
                                                .thenReturn([]);
            
            dao.when.findCell(AnyArgs()).thenReturn(mockedCellData('20170504A.h5', {'c1', 'c2', 'c3'}))... % belongs to already parsed file
                                        .thenReturn(mockedCellData('20170505A.h5', {'c1', 'c2'})); % belongs to newly parsed file

            experiments = {'20170504A', '20170505A'};
            expectedCellIdList =  [strcat({'20170504A'}, {'c1' , 'c2', 'c3'}), strcat({'20170505A'}, {'c1', 'c2'})];

            % Inject the mocks
            obj.manager.analysisDao = dao; 
            obj.manager.parserFactory = obj.parserFactoryMock; 

            % create a simple project
            p = sa_labs.analysis.entity.AnalysisProject();
            p.identifier = 'test-project';
            p.experimentList = experiments;
            p.analysisDate = datestr(now, obj.DATE_FORMAT);
            p.performedBy = 'sathish';
            p.description = 'Test project';
            p.file = 'test';
            m = obj.manager.createProject(p);

            obj.verifyNotEmpty(m);
            obj.verifyEmpty(setdiff(p.cellDataIdList, expectedCellIdList));
            obj.verifyLength(p.getCellDataArray(), 5);
            p %#ok

            % TODO test the exceptional scenarios
        end

        function testInitializeProject(obj)
        end

        function testPreprocess(obj)
        end

        function testBuildAnalysis(obj)
        end
        
    end
    
end

