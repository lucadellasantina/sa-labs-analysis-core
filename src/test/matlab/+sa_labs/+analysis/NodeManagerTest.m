classdef NodeManagerTest < matlab.unittest.TestCase
    
    properties
        s
        manager
    end
    
    methods (TestClassSetup)
        
        function create(obj)
            
            import sa_labs.analysis.*;
            obj.s = struct();
            obj.manager = core.NodeManager(tree());
            
            obj.manager.setRootName('Light-step-analysis');
            obj.s.amp1 = obj.manager.addNode(1, 'Amp', 'Amplifier_ch1', entity.DataSet(1:500, 'none'));
            obj.s.amp2 = obj.manager.addNode(1, 'Amp', 'Amplifier_ch2', entity.DataSet(1:500, 'none'));
            
            obj.s.ds1 = obj.manager.addNode(obj.s.amp1, 'DataSet', 'Light_Step_20', entity.DataSet(1:250, 'Light_Step_20'));
            obj.s.ds2 = obj.manager.addNode(obj.s.amp1, 'DataSet', 'Light_Step_400', entity.DataSet(251:500, 'Light_Step_400'));
            obj.s.ds3 = obj.manager.addNode(obj.s.amp2, 'DataSet', 'Light_Step_20', entity.DataSet(1:250, 'Light_Step_20'));
            obj.s.ds4 = obj.manager.addNode(obj.s.amp2, 'DataSet', 'Light_Step_400', entity.DataSet(251:500, 'Light_Step_400'));
            
            obj.s.ds1_rstar_0_01 = obj.manager.addNode(obj.s.ds1, 'rstar', '0.01',  entity.DataSet(1:2:250, 'rstar'));
            obj.s.ds1_rstar_0_1 = obj.manager.addNode(obj.s.ds1, 'rstar', '0.1',  entity.DataSet(2:2:250, 'rstar'));
            obj.s.ds2_rstar_0_01 = obj.manager.addNode(obj.s.ds2, 'rstar', '0.01', entity.DataSet(1:2:250, 'rstar'));
            obj.s.ds2_rstar_0_1 = obj.manager.addNode(obj.s.ds2, 'rstar', '0.1',  entity.DataSet(2:2:250, 'rstar'));
            obj.s.ds3_rstar_0_01 = obj.manager.addNode(obj.s.ds3, 'rstar', '0.01', entity.DataSet(1:2:250, 'rstar'));
            obj.s.ds3_rstar_0_1 = obj.manager.addNode(obj.s.ds3, 'rstar', '0.1',  entity.DataSet(2:2:250, 'rstar'));
            obj.s.ds4_rstar_0_01 = obj.manager.addNode(obj.s.ds4, 'rstar', '0.01', entity.DataSet(1:2:250, 'rstar'));
            obj.s.ds4_rstar_0_1 = obj.manager.addNode(obj.s.ds4, 'rstar', '0.1',  entity.DataSet(2:2:250, 'rstar'));
            
            disp('Tree information - ');
            obj.manager.getStructure().tostring() % print tree
        end
    end
    
    methods(Test)
        
        function testFindNodesByName(obj)
            
            % Root node check
            nodes = obj.manager.findNodesByName('light-step-analysis');
            obj.verifyLength(nodes, 1);
            obj.verifyEqual(nodes.id, 1);
            
            nodes = obj.manager.findNodesByName('Amp');
            obj.verifyLength(nodes, 2);
            obj.verifyEqual(nodes(1).id, obj.s.amp1);
            obj.verifyEqual(nodes(2).id, obj.s.amp2);
            obj.verifyEqual({nodes(:).name}, { 'Amp==Amplifier_ch1', 'Amp==Amplifier_ch2' });
            
            for i = 1 : numel(nodes)
                obj.verifyEqual(nodes(i).epochIndices, 1:500);
            end
            % Boundry cases
            nodes = obj.manager.findNodesByName('unknown');
            obj.verifyEmpty(nodes);
            nodes = obj.manager.findNodesByName([]);
            obj.verifyEmpty(nodes);
        end
        
        function testGetAllChildrensByName(obj)
            nodes = obj.manager.getAllChildrensByName('Light_Step_20');
            obj.verifyLength(nodes, 6);
            % dfs traversal check
            expected = [obj.s.ds1, obj.s.ds1_rstar_0_01, obj.s.ds1_rstar_0_1,...
                obj.s.ds3, obj.s.ds3_rstar_0_01, obj.s.ds3_rstar_0_1 ];
            obj.verifyEqual([nodes(:).id], expected);
            % Boundry cases
            nodes = obj.manager.findNodesByName('unknown');
            obj.verifyEmpty(nodes);
            nodes = obj.manager.findNodesByName([]);
            obj.verifyEmpty(nodes);
        end
        
        function testGetImmediateChildrensByName(obj)
            nodes = obj.manager.getImmediateChildrensByName('Amp');
            expected = [obj.s.ds1, obj.s.ds2, obj.s.ds3, obj.s.ds4];
            obj.verifyEqual([nodes(:).id], expected);
            % Boundry cases
            nodes = obj.manager.findNodesByName('unknown');
            obj.verifyEmpty(nodes);
            nodes = obj.manager.findNodesByName([]);
            obj.verifyEmpty(nodes);
        end
        
        function testPercolateUp(obj)
            childNodes = obj.manager.findNodesByName('rstar');
            % prepare child nodes for additional parameters
            parameters = struct();
            parameters.ndf = {'a1a', 'a2a'};
            parameters.array = 1:5;
            for i = 1 : numel(childNodes)
                childNodes(i).setParameters(parameters);
            end
            % get amplifier nodes
            amp1LigstepsNodes = obj.manager.findNodesByName('Light_Step_20');
            amp1Ligstep = amp1LigstepsNodes(1);
            obj.manager.percolateUp([childNodes(:).id], 'splitValue', 'rstar_from_child')
            
            obj.verifyEqual(amp1Ligstep.getParameter('rstar_from_child'), {'0.01', '0.1'});
            handle = @()obj.manager.percolateUp([childNodes(:).id], 'splitValue', 'splitValue');
            obj.verifyError(handle,'MATLAB:class:SetProhibited');
        end
    end
end

