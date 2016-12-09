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
        
        function testGetEpochs(obj)
            import sa_labs.analysis.*;
            
            cellData = entity.CellData();
            epochs = entity.EpochData.empty(0, 10);
            for i = 1 : 10
                epochs(i) = entity.EpochData();
                epochs(i).attributes('id') = i;
            end
            cellData.epochs = epochs;
            
            obj.extractor.epochIterator = @(indices) cellData.epochs(indices);
            node = entity.Node('test', 1);
            node.epochIndices = [1, 5, 8];
            
            actualEpochs = obj.extractor.getEpochs(node);
            
            for i = 1 : 3
                obj.verifyEqual(node.epochIndices(i), actualEpochs(i).attributes('id'));
            end
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
            
            obj.extractor.epochIterator = @(indices) epochs(node.epochIndices);
            
            actualResponse = obj.extractor.getResponse(node, 'Amp1');
            obj.verifyEqual(actualResponse, [obj.noise + 1; obj.noise + 5; obj.noise + 7]);
        end
        
        function testDelegate(obj)
            import sa_labs.analysis.*;
            
            f = {'@(obj, node) extractor(obj, node, ''param1'', ''value1'', ''param2'', ''value2'')'};
            
            splitParameter = 'testNode';
            nodes = entity.Node.empty(0, 3);
            for i = 1 : 3
                nodes(i) = entity.Node(splitParameter, i);
                nodes(i).epochIndices = i * [1, 2, 3];
            end
            
            simpleExtractor = sa_labs.test_extractor.SimpleExtractor();
            simpleExtractor.testInstance = obj;
            
            simpleExtractor.nodeManager = Mock(sa_labs.analysis.core.NodeManager(tree()));
            simpleExtractor.nodeManager.when.findNodesByName(AnyArgs()).thenReturn(nodes, [1,2,3]);
            simpleExtractor.nodeManager.when.percolateUp(AnyArgs()).thenReturn([]);
            
            simpleExtractor.delegate(f, splitParameter);
            % Look up on test_extractor.SimpleExtractor.extractor for validation logic
            
            obj.verifyEqual(simpleExtractor.callstack, 3);
        end
    end   
end

