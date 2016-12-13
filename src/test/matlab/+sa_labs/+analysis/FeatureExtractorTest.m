classdef FeatureExtractorTest < matlab.unittest.TestCase
    
    properties
        extractor
        noise
    end
    
    methods (TestClassSetup)
        
        function create(obj)
            obj.extractor = sa_labs.analysis.core.FeatureExtractor();
            obj.noise = randn(1,10000);
        end
    end
    
    methods(Test)
        
        function testReadCSV(obj)
            import sa_labs.analysis.*;
            
            fname = app.App.getResource(app.Constants.FEATURE_DESC_FILE_NAME);
            fname = strrep(fname, 'main', 'test');
            r = obj.extractor.readCSV(fname);
            
            obj.verifyEqual(r(1, :), {'id', 'description' ,'strategy',....
                'unit', 'chartType', 'xAxis', 'properties'});
            obj.verifyEqual(r(2 : end, 1)', {'TEST_FIRST', 'TEST_SECOND'});
            obj.verifyEqual(size(r), [3, 7]);
        end
        
        function testLoadFeatureDescription(obj)
            import sa_labs.analysis.*;
            
            fname = app.App.getResource(app.Constants.FEATURE_DESC_FILE_NAME);
            fname = strrep(fname, 'main', 'test');
            obj.extractor.loadFeatureDescription(fname);
            actual = obj.extractor.descriptionMap;
            obj.verifyEqual(actual.keys, {'TEST_FIRST', 'TEST_SECOND'});
            
            % validate TEST_FIRST
            description = actual('TEST_FIRST');
            obj.verifyEqual(description.id, 'TEST_FIRST');
            obj.verifyEqual(description.strategy, 'Epoch');
            obj.verifyEqual(description.binWidth, '100');
        end
        
        function testCreate(obj)
            import sa_labs.analysis.*;
            
            t = struct();
            t.extractorClazz = 'sa_labs.test_extractor.SimpleExtractor';
            instance = core.FeatureExtractor.create(t);
            obj.verifyClass(instance, ?sa_labs.test_extractor.SimpleExtractor);
            
            t.extractorClazz = 'sa_labs.analysis.core.FeatureExtractor';
            instance = core.FeatureExtractor.create(t);
            obj.verifyClass(instance, ?sa_labs.analysis.core.FeatureExtractor);
            
            t.extractorClazz = 'struct';
            handle = @()sa_labs.analysis.core.FeatureExtractor.create(t);
            obj.verifyError(handle, app.Exceptions.MISMATCHED_EXTRACTOR_TYPE.msgId);
        end
        
        function testDelegate(obj)
            import sa_labs.analysis.*;
            
            f = {'@(obj, node) extractor(obj, node, ''param1'', ''value1'', ''param2'', ''value2'')'};
            
            splitParameter = 'testNode';
            nodes = entity.Node.empty(0, 3);
            for i = 1 : 3
                nodes(i) = entity.Node(splitParameter, i);
                nodes(i).epochIndices = i * [1, 2, 3];
                nodes(i).id = i;
            end
            
            simpleExtractor = sa_labs.test_extractor.SimpleExtractor();
            simpleExtractor.testInstance = obj;
            
            simpleExtractor.nodeManager = Mock(sa_labs.analysis.core.NodeManager(tree()));
            simpleExtractor.nodeManager.when.findNodesByName(AnyArgs()).thenReturn(nodes, [1,2,3]);
            simpleExtractor.nodeManager.when.percolateUp(AnyArgs()).thenReturn([]);
            simpleExtractor.nodeManager.when.isAnalysisOnline(AnyArgs()).thenReturn(false);
            
            simpleExtractor.delegate(f, nodes);
            % Look up on test_extractor.SimpleExtractor.extractor for validation logic
            
            obj.verifyEqual(simpleExtractor.callstack, 3);
        end
        
        function testGetResponse(obj)
            import sa_labs.analysis.*;
            
            % Mockito is not working for array of mock objects
            % Error using Mock/subsref (line 121)
            % Must call a function on the mock object
            
            epochs = entity.EpochData.empty(0, 10);
            for i = 1 : 10
                epochs(i) = entity.EpochData();
                epochs(i).dataLinks = containers.Map('Amp1', 'path');
                epochs(i).responseHandle =  @(a) obj.noise + i;
            end
            
            node = entity.Node('test', 1);
            node.epochIndices = [1, 5, 7];
            
            obj.extractor.epochStream = @(indices) epochs(node.epochIndices);
            obj.extractor.nodeManager = Mock(core.NodeManager());
            obj.extractor.nodeManager.when.isAnalysisOnline(AnyArgs()).thenReturn(false);
            
            actualResponse = obj.extractor.getResponse(node, 'Amp1');
            obj.verifyEqual(actualResponse, [obj.noise + 1; obj.noise + 5; obj.noise + 7]);
        end
        
        function testGetEpochs(obj)
            import sa_labs.analysis.*;
            
            cellData = entity.CellData();
            epochs = entity.EpochData.empty(0, 10);
            for i = 1 : 10
                epochs(i) = entity.EpochData();
                epochs(i).attributes('id') = i;
            end
            cellData.epochs = epochs;
            
            obj.extractor.epochStream = @(indices) cellData.epochs(indices);
            obj.extractor.nodeManager = Mock(core.NodeManager());
            obj.extractor.nodeManager.when.isAnalysisOnline(AnyArgs()).thenReturn(false);
            
            node = entity.Node('test', 1);
            node.epochIndices = [1, 5, 8];
            
            actualEpochs = obj.extractor.getEpochs(node);
            
            for i = 1 : 3
                obj.verifyEqual(node.epochIndices(i), actualEpochs(i).attributes('id'));
            end
        end
    end
end

