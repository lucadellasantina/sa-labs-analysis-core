classdef NodeManagerTest < matlab.unittest.TestCase
    
    properties
        s
        manager
    end
    
    methods (TestClassSetup)
        
        function create(obj)
            
            import symphony.analysis.core.*;
            obj.s = struct();
            obj.manager = NodeManager(tree());
            
            obj.manager.setName('Light-step-analysis');
            obj.s.amp1 = obj.manager.addNode(1, 'Amp', 'Amplifier_ch1', 1:500);
            obj.s.amp2 = obj.manager.addNode(1, 'Amp', 'Amplifier_ch2', 1:500);
            
            obj.s.ds1 = obj.manager.addNode(obj.s.amp1, 'DataSet', 'Light_Step_20', 1:250);
            obj.s.ds2 = obj.manager.addNode(obj.s.amp1, 'DataSet', 'Light_Step_400', 251:500);
            obj.s.ds3 = obj.manager.addNode(obj.s.amp2, 'DataSet', 'Light_Step_20', 1:250);
            obj.s.ds4 = obj.manager.addNode(obj.s.amp2, 'DataSet', 'Light_Step_400', 251:500);
            
            obj.s.ds1_rstar_0_01 = obj.manager.addNode(obj.s.ds1, 'rstar', '0.01', 1:2:250);
            obj.s.ds1_rstar_0_1 = obj.manager.addNode(obj.s.ds1, 'rstar', '0.1', 2:2:250);
            obj.s.ds2_rstar_0_01 = obj.manager.addNode(obj.s.ds2, 'rstar', '0.01', 1:2:250);
            obj.s.ds2_rstar_0_1 = obj.manager.addNode(obj.s.ds2, 'rstar', '0.1', 2:2:250);
            obj.s.ds3_rstar_0_01 = obj.manager.addNode(obj.s.ds3, 'rstar', '0.01', 1:2:250);
            obj.s.ds3_rstar_0_1 = obj.manager.addNode(obj.s.ds3, 'rstar', '0.1', 2:2:250);
            obj.s.ds4_rstar_0_01 = obj.manager.addNode(obj.s.ds4, 'rstar', '0.01', 1:2:250);
            obj.s.ds4_rstar_0_1 = obj.manager.addNode(obj.s.ds4, 'rstar', '0.1', 2:2:250);
            
        end
    end
    
    methods(Test)
        
        function testFindNodesByName(obj)
            
            nodes = obj.manager.findNodesByName('Amp');
            obj.verifyLength(nodes, 2);
            obj.verifyEqual(nodes(1).id, obj.s.amp1);
            obj.verifyEqual(nodes(2).id, obj.s.amp2);
            obj.verifyEqual({nodes(:).name}, { 'Amp==Amplifier_ch1', 'Amp==Amplifier_ch2' })
        end
        
        function testGetAllChildrensByName(obj)
            nodes = obj.manager.getAllChildrensByName('DataSet==Light_Step_20');
            obj.verifyLength(nodes, 6);
            % dfs traversal
            expected = [obj.s.ds1, obj.s.ds1_rstar_0_01, obj.s.ds1_rstar_0_1,...
                obj.s.ds3, obj.s.ds3_rstar_0_01, obj.s.ds3_rstar_0_1 ];
            obj.verifyEqual([nodes(:).id], expected);
        end
        
        function testGetImmediateChildrensByName(obj)
            nodes = obj.manager.getImmediateChildrensByName('Amp');
            expected = [obj.s.ds1, obj.s.ds2, obj.s.ds3, obj.s.ds4];
            obj.verifyEqual([nodes(:).id], expected);
        end
    end
end

