classdef OfflineAnalysisManagerTest < matlab.unittest.TestCase
    
    properties
        beanFactory
        manager
    end
    
    methods (TestClassSetup)
        
        function initContext(obj)
            import sa_labs.analysis.*;
            obj.beanFactory = mdepin.getBeanFactory(which('TestContext.m'));
            obj.manager = obj.beanFactory.getBean('offlineAnalaysisManager');
        end
    end
    
    methods(Test)
        
        function testParseSymphonyFiles(obj)
            dao = obj.manager.analysisDao;
            dao.when.findRawDataFiles(AnyArgs()).thenReturn({'20170505A.h5'})...
                                                .thenReturn({'20170504A.h5', '20170505A.h5'})...
                                                .thenReturn([]);  % for exception scenario

            % not mocking the cell data since arrays of mock wont work
            cellData(1) = sa_labs.analysis.entity.CellData();
            cellData(1).recordingLabel = 'one';

            cellData(2) = sa_labs.analysis.entity.CellData();
            cellData(2).recordingLabel = 'two';

            parserMock = Mock();

            obj.manager.parserFactory.when.getInstance(AnyArgs()).thenReturn(parserMock).times(100);
            parserMock.when.parse(AnyArgs()).thenReturn(cellData).times(100);
            
            actual = obj.manager.parseSymphonyFiles('20170505A');
            
            obj.verifyLength(actual, 2);
            obj.verifyEmpty(setdiff({actual.recordingLabel}, {cellData.recordingLabel}));
            
            actual = obj.manager.parseSymphonyFiles('201705');
            obj.verifyLength(actual, 4);
            obj.verifyEmpty(setdiff({actual.recordingLabel}, {cellData.recordingLabel}));

            handle = @() obj.manager.parseSymphonyFiles('unknown');
            obj.verifyError(handle, sa_labs.analysis.app.Exceptions.NO_RAW_DATA_FOUND.msgId);
        end
    end
    
end

