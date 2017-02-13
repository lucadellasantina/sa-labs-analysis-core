classdef FeatureManagerTest < matlab.unittest.TestCase
    
    properties
        manager
        analysisProtocol
        treeIndices
    end
    
    methods (TestClassSetup)
        
        function create(obj)
            
            import sa_labs.analysis.*;
            obj.treeIndices = struct();
            obj.analysisProtocol = struct('type', 'Light-step-analysis');
            obj.analysisProtocol.featureManager = 'sa_labs.analysis.core.FeatureTreeManager';
            obj.analysisProtocol.buildTreeBy = {'unknown'};
            obj.manager = core.FeatureManager.create(core.AnalysisProtocol(obj.analysisProtocol), core.AnalysisMode.OFFLINE_ANALYSIS);
            
            obj.treeIndices.amp1 = obj.manager.addFeatureGroup(1, 'Amp', 'Amplifier_ch1', entity.EpochGroup(1:500, 'none'));
            obj.treeIndices.amp2 = obj.manager.addFeatureGroup(1, 'Amp', 'Amplifier_ch2', entity.EpochGroup(1:500, 'none'));
            
            obj.treeIndices.ds1 = obj.manager.addFeatureGroup(obj.treeIndices.amp1, 'EpochGroup', 'Light_Step_20', entity.EpochGroup(1:250, 'Light_Step_20'));
            obj.treeIndices.ds2 = obj.manager.addFeatureGroup(obj.treeIndices.amp1, 'EpochGroup', 'Light_Step_400', entity.EpochGroup(251:500, 'Light_Step_400'));
            obj.treeIndices.ds3 = obj.manager.addFeatureGroup(obj.treeIndices.amp2, 'EpochGroup', 'Light_Step_20', entity.EpochGroup(1:250, 'Light_Step_20'));
            obj.treeIndices.ds4 = obj.manager.addFeatureGroup(obj.treeIndices.amp2, 'EpochGroup', 'Light_Step_400', entity.EpochGroup(251:500, 'Light_Step_400'));
            
            obj.treeIndices.ds1_rstar_0_01 = obj.manager.addFeatureGroup(obj.treeIndices.ds1, 'rstar', '0.01',  entity.EpochGroup(1:2:250, 'rstar'));
            obj.treeIndices.ds1_rstar_0_1 = obj.manager.addFeatureGroup(obj.treeIndices.ds1, 'rstar', '0.1',  entity.EpochGroup(2:2:250, 'rstar'));
            obj.treeIndices.ds2_rstar_0_01 = obj.manager.addFeatureGroup(obj.treeIndices.ds2, 'rstar', '0.01', entity.EpochGroup(1:2:250, 'rstar'));
            obj.treeIndices.ds2_rstar_0_1 = obj.manager.addFeatureGroup(obj.treeIndices.ds2, 'rstar', '0.1',  entity.EpochGroup(2:2:250, 'rstar'));
            obj.treeIndices.ds3_rstar_0_01 = obj.manager.addFeatureGroup(obj.treeIndices.ds3, 'rstar', '0.01', entity.EpochGroup(1:2:250, 'rstar'));
            obj.treeIndices.ds3_rstar_0_1 = obj.manager.addFeatureGroup(obj.treeIndices.ds3, 'rstar', '0.1',  entity.EpochGroup(2:2:250, 'rstar'));
            obj.treeIndices.ds4_rstar_0_01 = obj.manager.addFeatureGroup(obj.treeIndices.ds4, 'rstar', '0.01', entity.EpochGroup(1:2:250, 'rstar'));
            obj.treeIndices.ds4_rstar_0_1 = obj.manager.addFeatureGroup(obj.treeIndices.ds4, 'rstar', '0.1',  entity.EpochGroup(2:2:250, 'rstar'));
            
            disp('Tree information - ');
            obj.manager.getStructure().tostring() % print tree
        end
    end
    
    % Test for feature manager methods
    
    methods(Test)
        
        function testReadCSV(obj)
            import sa_labs.analysis.*;
            
            fname = app.App.getResource(app.Constants.FEATURE_DESC_FILE_NAME);
            fname = strrep(fname, 'main', 'test');
            r = util.file.readCSVToCell(fname, core.FeatureManager.FORMAT_SPECIFIER);
            
            obj.verifyEqual(r(1, :), {'id', 'description' ,'strategy',....
                'unit', 'chartType', 'xAxis', 'properties'});
            obj.verifyEqual(r(2 : end, 1)', {'TEST_FIRST', 'TEST_SECOND'});
            obj.verifyEqual(size(r), [3, 7]);
        end
        
        function testLoadFeatureDescription(obj)
            import sa_labs.analysis.*;
            
            fname = app.App.getResource(app.Constants.FEATURE_DESC_FILE_NAME);
            fname = strrep(fname, 'main', 'test');
            obj.verifyWarning(@()obj.manager.loadFeatureDescription(fname), 'featureManager:reloadDescriptionCSV');
            actual = obj.manager.descriptionMap;
            obj.verifyEqual(actual.keys, {'TEST_FIRST', 'TEST_SECOND'});
            
            % validate TEST_FIRST
            description = actual('TEST_FIRST');
            obj.verifyEqual(description.id, 'TEST_FIRST');
            obj.verifyEqual(description.strategy, 'Epoch');
            obj.verifyEqual(description.binWidth, '100');
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
            
            obj.manager.epochStream = @(indices) cellData.epochs(indices);
            node = entity.FeatureGroup('test', 1);
            node.epochIndices = [1, 5, 8];

            actualEpochs = obj.manager.getEpochs(node);
            for i = 1 : 3
                obj.verifyEqual(node.epochIndices(i), actualEpochs(i).attributes('id'));
            end
        end
    end
    
    % Test for Feature Tree Manager methods
    
    methods (Test)
        
        function testFindFeatureGroup(obj)
            
            % Root node check
            nodes = obj.manager.findFeatureGroup('Light-step-analysis');
            obj.verifyLength(nodes, 1);
            obj.verifyEqual(nodes.id, 1);
            
            nodes = obj.manager.findFeatureGroup('Amp');
            obj.verifyLength(nodes, 2);
            obj.verifyEqual(nodes(1).id, obj.treeIndices.amp1);
            obj.verifyEqual(nodes(2).id, obj.treeIndices.amp2);
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
            expected = [obj.treeIndices.ds1, obj.treeIndices.ds1_rstar_0_01, obj.treeIndices.ds1_rstar_0_1,...
                obj.treeIndices.ds3, obj.treeIndices.ds3_rstar_0_01, obj.treeIndices.ds3_rstar_0_1 ];
            obj.verifyEqual([nodes(:).id], expected);
            % Boundry cases
            nodes = obj.manager.findFeatureGroup('unknown');
            obj.verifyEmpty(nodes);
            nodes = obj.manager.findFeatureGroup([]);
            obj.verifyEmpty(nodes);
        end
        
        function testGetImmediateChildrensByName(obj)
            nodes = obj.manager.getImmediateChildrensByName('Amp');
            expected = [obj.treeIndices.ds1, obj.treeIndices.ds2, obj.treeIndices.ds3, obj.treeIndices.ds4];
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
            n = obj.manager.getFeatureGroups(obj.treeIndices.ds4_rstar_0_1);
            obj.verifyEqual(n.id, obj.treeIndices.ds4_rstar_0_1);
        end
        
        function testFindFeatureGroupId(obj)
            id = obj.manager.findFeatureGroupId('Amp==Amplifier_ch1');
            obj.verifyEqual(id, obj.treeIndices.amp1);
            
            % search on ds4 subtree
            id = obj.manager.findFeatureGroupId('rstar==0.01', obj.treeIndices.ds4);
            obj.verifyEqual(id, obj.treeIndices.ds4_rstar_0_01);
            
            % valid subtree but invalid search expression
            id = obj.manager.findFeatureGroupId('Light_Step_500', obj.treeIndices.amp2);
            obj.verifyEmpty(id);            
        end
        
        function validateNodeIdAfterTreeMerge(obj)
            import sa_labs.analysis.*;
            
            expectedFirstLeaf = obj.manager.getFeatureGroups(obj.treeIndices.ds1_rstar_0_01);
            expecteLastLeaf = obj.manager.getFeatureGroups(obj.treeIndices.ds4_rstar_0_1);
            n = obj.manager.dataStore.nnodes;
            
            obj.analysisProtocol.type = 'Light-step-extended-analysis';
            m = core.FeatureManager.create(core.AnalysisProtocol(obj.analysisProtocol), core.AnalysisMode.OFFLINE_ANALYSIS);
            
            m.addFeatureGroup(1, 'Amp', 'Amplifier_ch3', entity.EpochGroup(1:500, 'none'));
            m.addFeatureGroup(1, 'Amp', 'Amplifier_ch4', entity.EpochGroup(1:500, 'none'));
            % validate leaf
            disp(' Merging tree ');
            obj.manager.append(m.dataStore);
            actual = obj.manager.getFeatureGroups(obj.treeIndices.ds1_rstar_0_01);
            obj.verifyEqual(actual.name, expectedFirstLeaf.name);
            
            actual = obj.manager.getFeatureGroups(obj.treeIndices.ds4_rstar_0_1);
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
            obj.analysisProtocol.type = 'Light-step-extended-analysis';
            m = core.FeatureManager.create(core.AnalysisProtocol(obj.analysisProtocol), core.AnalysisMode.OFFLINE_ANALYSIS);
            % empty check
            obj.verifyFalse(m.isBasicFeatureGroup([]));
            id = m.addFeatureGroup(1, 'Amp', 'Amplifier_ch3', entity.EpochGroup(1:500, 'none'));
            
            obj.verifyTrue(m.isBasicFeatureGroup(m.getFeatureGroups(id)));
            id = m.addFeatureGroup(id, 'rstar', '0.01', entity.EpochGroup(1:500, 'none'));
            
            obj.verifyFalse(m.isBasicFeatureGroup(m.getFeatureGroups(1)));
            obj.verifyTrue(m.isBasicFeatureGroup(m.getFeatureGroups(id)));
            
            m = obj.manager;
            % array of nodes
            obj.verifyTrue(m.isBasicFeatureGroup(m.getFeatureGroups([obj.treeIndices.ds1_rstar_0_01, obj.treeIndices.ds4_rstar_0_1])));
            obj.verifyFalse(m.isBasicFeatureGroup(m.getFeatureGroups([obj.treeIndices.ds1_rstar_0_01, obj.treeIndices.ds4_rstar_0_1, obj.treeIndices.ds4])));
        end

    end
end

