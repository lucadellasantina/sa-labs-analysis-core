classdef FeatureTreeManagerTest < matlab.unittest.TestCase
    
    properties
        s
        manager
    end
    
    methods (TestClassSetup)
        
        function create(obj)
            
            import sa_labs.analysis.*;
            obj.s = struct();
            obj.manager = core.FeatureTreeManager(tree());
            
            obj.manager.setRootName('Light-step-analysis');
            obj.s.amp1 = obj.manager.addFeatureGroup(1, 'Amp', 'Amplifier_ch1', entity.EpochGroup(1:500, 'none'));
            obj.s.amp2 = obj.manager.addFeatureGroup(1, 'Amp', 'Amplifier_ch2', entity.EpochGroup(1:500, 'none'));
            
            obj.s.ds1 = obj.manager.addFeatureGroup(obj.s.amp1, 'EpochGroup', 'Light_Step_20', entity.EpochGroup(1:250, 'Light_Step_20'));
            obj.s.ds2 = obj.manager.addFeatureGroup(obj.s.amp1, 'EpochGroup', 'Light_Step_400', entity.EpochGroup(251:500, 'Light_Step_400'));
            obj.s.ds3 = obj.manager.addFeatureGroup(obj.s.amp2, 'EpochGroup', 'Light_Step_20', entity.EpochGroup(1:250, 'Light_Step_20'));
            obj.s.ds4 = obj.manager.addFeatureGroup(obj.s.amp2, 'EpochGroup', 'Light_Step_400', entity.EpochGroup(251:500, 'Light_Step_400'));
            
            obj.s.ds1_rstar_0_01 = obj.manager.addFeatureGroup(obj.s.ds1, 'rstar', '0.01',  entity.EpochGroup(1:2:250, 'rstar'));
            obj.s.ds1_rstar_0_1 = obj.manager.addFeatureGroup(obj.s.ds1, 'rstar', '0.1',  entity.EpochGroup(2:2:250, 'rstar'));
            obj.s.ds2_rstar_0_01 = obj.manager.addFeatureGroup(obj.s.ds2, 'rstar', '0.01', entity.EpochGroup(1:2:250, 'rstar'));
            obj.s.ds2_rstar_0_1 = obj.manager.addFeatureGroup(obj.s.ds2, 'rstar', '0.1',  entity.EpochGroup(2:2:250, 'rstar'));
            obj.s.ds3_rstar_0_01 = obj.manager.addFeatureGroup(obj.s.ds3, 'rstar', '0.01', entity.EpochGroup(1:2:250, 'rstar'));
            obj.s.ds3_rstar_0_1 = obj.manager.addFeatureGroup(obj.s.ds3, 'rstar', '0.1',  entity.EpochGroup(2:2:250, 'rstar'));
            obj.s.ds4_rstar_0_01 = obj.manager.addFeatureGroup(obj.s.ds4, 'rstar', '0.01', entity.EpochGroup(1:2:250, 'rstar'));
            obj.s.ds4_rstar_0_1 = obj.manager.addFeatureGroup(obj.s.ds4, 'rstar', '0.1',  entity.EpochGroup(2:2:250, 'rstar'));
            
            disp('Tree information - ');
            obj.manager.getStructure().tostring() % print tree
        end
    end
    
    methods(Test)
        
        function testFindFeatureGroup(obj)
            
            % Root node check
            nodes = obj.manager.findFeatureGroup('light-step-analysis');
            obj.verifyLength(nodes, 1);
            obj.verifyEqual(nodes.id, 1);
            
            nodes = obj.manager.findFeatureGroup('Amp');
            obj.verifyLength(nodes, 2);
            obj.verifyEqual(nodes(1).id, obj.s.amp1);
            obj.verifyEqual(nodes(2).id, obj.s.amp2);
            obj.verifyEqual({nodes(:).name}, { 'Amp==Amplifier_ch1', 'Amp==Amplifier_ch2' });
            
            for i = 1 : numel(nodes)
                obj.verifyEqual(nodes(i).epochIndices, 1:500);
            end
            % Boundry cases
            nodes = obj.manager.findFeatureGroup('unknown');
            obj.verifyEmpty(nodes);
            nodes = obj.manager.findFeatureGroup([]);
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
            nodes = obj.manager.findFeatureGroup('unknown');
            obj.verifyEmpty(nodes);
            nodes = obj.manager.findFeatureGroup([]);
            obj.verifyEmpty(nodes);
        end
        
        function testGetImmediateChildrensByName(obj)
            nodes = obj.manager.getImmediateChildrensByName('Amp');
            expected = [obj.s.ds1, obj.s.ds2, obj.s.ds3, obj.s.ds4];
            obj.verifyEqual([nodes(:).id], expected);
            % Boundry cases
            nodes = obj.manager.findFeatureGroup('unknown');
            obj.verifyEmpty(nodes);
            nodes = obj.manager.findFeatureGroup([]);
            obj.verifyEmpty(nodes);
        end
        
        function testCopyFeaturesToGroup(obj)
            childNodes = obj.manager.findFeatureGroup('rstar');
            % prepare child nodes for additional parameters
            parameters = struct();
            parameters.ndf = {'a1a', 'a2a'};
            parameters.array = 1:5;
            for i = 1 : numel(childNodes)
                childNodes(i).setParameters(parameters);
            end
            % get amplifier nodes
            amp1LigstepsNodes = obj.manager.findFeatureGroup('Light_Step_20');
            amp1Ligstep = amp1LigstepsNodes(1);
            obj.manager.copyFeaturesToGroup([childNodes(:).id], 'splitValue', 'rstar_from_child')
            
            obj.verifyEqual(amp1Ligstep.getParameter('rstar_from_child'), {'0.01', '0.1'});
            handle = @()obj.manager.copyFeaturesToGroup([childNodes(:).id], 'splitValue', 'splitValue');
            obj.verifyError(handle,'MATLAB:class:SetProhibited');
        end
        
        function testGetFeatureGroups(obj)
            % check for null indices
            n = obj.manager.getFeatureGroups([]);
            obj.verifyEmpty(n);
            
            % single node check
            n = obj.manager.getFeatureGroups(obj.s.ds4_rstar_0_1);
            obj.verifyEqual(n.id, obj.s.ds4_rstar_0_1);
        end
        
        function testFindFeatureGroupId(obj)
            id = obj.manager.findFeatureGroupId('Amp==Amplifier_ch1');
            obj.verifyEqual(id, obj.s.amp1);
            
            % search on ds4 subtree
            id = obj.manager.findFeatureGroupId('rstar==0.01', obj.s.ds4);
            obj.verifyEqual(id, obj.s.ds4_rstar_0_01);
            
            % valid subtree but invalid search expression
            id = obj.manager.findFeatureGroupId('Light_Step_500', obj.s.amp2);
            obj.verifyEmpty(id);            
        end
        
        function validateNodeIdAfterTreeMerge(obj)
            import sa_labs.analysis.*;
            
            expectedFirstLeaf = obj.manager.getFeatureGroups(obj.s.ds1_rstar_0_01);
            expecteLastLeaf = obj.manager.getFeatureGroups(obj.s.ds4_rstar_0_1);
            n = obj.manager.dataStore.nnodes;
            
            m = core.FeatureTreeManager(tree());
            m.setRootName('Light-step-extended-analysis');
            m.addFeatureGroup(1, 'Amp', 'Amplifier_ch3', entity.EpochGroup(1:500, 'none'));
            m.addFeatureGroup(1, 'Amp', 'Amplifier_ch4', entity.EpochGroup(1:500, 'none'));
            % validate leaf
            disp(' Merging tree ');
            obj.manager.append(m.dataStore);
            actual = obj.manager.getFeatureGroups(obj.s.ds1_rstar_0_01);
            obj.verifyEqual(actual.name, expectedFirstLeaf.name);
            
            actual = obj.manager.getFeatureGroups(obj.s.ds4_rstar_0_1);
            obj.verifyEqual(actual.name, expecteLastLeaf.name);
            
            % non leaf nodes
            actual = obj.manager.findFeatureGroup('Amp==Amplifier_ch3');
            obj.verifyEqual(actual.id, n + 2);
            actual = obj.manager.findFeatureGroup('Amp==Amplifier_ch4');
            obj.verifyEqual(actual.id, n + 3);
            
            obj.manager.getStructure().tostring() % print tree
        end
        
        function testBasicFeatureGroup(obj)
            import sa_labs.analysis.*;
            m = core.FeatureTreeManager(tree());
            % empty check
            obj.verifyFalse(m.isBasicFeatureGroup([]));
            
            m.setRootName('Light-step-extended-analysis');
            id = m.addFeatureGroup(1, 'Amp', 'Amplifier_ch3', entity.EpochGroup(1:500, 'none'));
            
            obj.verifyTrue(m.isBasicFeatureGroup(m.getFeatureGroups(id)));
            id = m.addFeatureGroup(id, 'rstar', '0.01', entity.EpochGroup(1:500, 'none'));
            
            obj.verifyFalse(m.isBasicFeatureGroup(m.getFeatureGroups(1)));
            obj.verifyTrue(m.isBasicFeatureGroup(m.getFeatureGroups(id)));
            
            m = obj.manager;
            % array of nodes
            obj.verifyTrue(m.isBasicFeatureGroup(m.getFeatureGroups([obj.s.ds1_rstar_0_01, obj.s.ds4_rstar_0_1])));
            obj.verifyFalse(m.isBasicFeatureGroup(m.getFeatureGroups([obj.s.ds1_rstar_0_01, obj.s.ds4_rstar_0_1, obj.s.ds4])));
        end

    end
end

