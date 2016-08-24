classdef OfflineAnalysisTest < matlab.unittest.TestCase
    
    methods(Test)
        
        function testBuildTreeSimple(obj)
            import sa_labs.analysis.*;
            
            levelTwo = containers.Map({'Amplifier_Ch1'}, {1 : 50});
            mockedCellData = Mock(entity.CellData());
            mockedCellData.savedDataSets('LightStep_20') = entity.DataSet(1 : 50, 'none');
            mockedCellData.when.getEpochValuesMap(AnyArgs()).thenReturn(levelTwo, 'deviceStream');
            
            % Tree with two level - analysis
            structure = struct();
            structure.type = 'test-analysis';
            structure.buildTreeBy = {'dataSet', 'deviceStream'};
            tree = testAnalyze();
            actual = tree.treefun(@(node) node.name);
            
            expected = {'test-analysis'; 'dataSet==LightStep_20'; 'deviceStream==Amplifier_Ch1'};
            obj.verifyEqual(actual.Node, expected);
            leafs = tree.findleaves();
            obj.verifyEqual(tree.get(leafs).epochIndices, 1:50);
            
            % Tree with two level and one branch - analysis
            levelTwoOtherBranch = containers.Map({'Amplifier_Ch1'}, {51 : 100});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.savedDataSets('LightStep_20') = entity.DataSet(1 : 50, 'none');
            mockedCellData.savedDataSets('LightStep_500') = entity.DataSet(51 : 100, 'none');
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(levelTwo, 'deviceStream')...
                .thenReturn(levelTwoOtherBranch, 'deviceStream');
            
            tree = testAnalyze();
            actual = tree.treefun(@(node) node.name);
            
            expected = {'test-analysis'; 'dataSet==LightStep_20'; 'deviceStream==Amplifier_Ch1'; 'dataSet==LightStep_500'; 'deviceStream==Amplifier_Ch1'};
            obj.verifyEqual(actual.Node, expected);
            leafs = tree.findleaves();
            obj.verifyEqual(tree.get(leafs(1)).epochIndices, 1:50);
            obj.verifyEqual(tree.get(leafs(2)).epochIndices, 51:100);
            
            % Tree with two level and two branch - analysis
            
            levelTwo = containers.Map({'Amplifier_Ch1', 'Amplifier_Ch2'}, {1 : 50, 1 : 50});
            levelTwoOtherBranch = containers.Map({'Amplifier_Ch1', 'Amplifier_Ch2'}, {51 : 100, 51 : 100});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.savedDataSets('LightStep_20') = entity.DataSet(1 : 50, 'none');
            mockedCellData.savedDataSets('LightStep_500') = entity.DataSet(51 : 100, 'none');
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(levelTwo, 'deviceStream')...
                .thenReturn(levelTwoOtherBranch, 'deviceStream');
            
            tree = testAnalyze();
            actual = tree.treefun(@(node) node.name);
            
            expected = {'test-analysis'; 'dataSet==LightStep_20'; 'deviceStream==Amplifier_Ch1';'deviceStream==Amplifier_Ch2';...
                'dataSet==LightStep_500'; 'deviceStream==Amplifier_Ch1';'deviceStream==Amplifier_Ch2'};
            
            obj.verifyEqual(actual.Node, expected);
            leafs = tree.findleaves();
            obj.verifyEqual(tree.get(leafs(1)).epochIndices, 1:50);
            obj.verifyEqual(tree.get(leafs(2)).epochIndices, 1:50);
            obj.verifyEqual(tree.get(leafs(3)).epochIndices, 51:100);
            obj.verifyEqual(tree.get(leafs(4)).epochIndices, 51:100);
            
            function tree = testAnalyze()
                import sa_labs.analysis.*;
                
                template = core.AnalysisTemplate(structure);
                offlineAnalysis = core.OfflineAnalysis('test-collective-analysis', mockedCellData);
                tree = offlineAnalysis.do(template);
                disp('analysis tree')
                tree.treefun(@(node) node.name).tostring()
            end
        end
        
        function testBuildTreeComplex(obj)
            import sa_labs.analysis.*;
            
            levelTwo = containers.Map({'Amplifier_Ch1', 'Amplifier_Ch2'}, {1 : 50,  1 : 25});
            levelThree = containers.Map({'G1', 'G2'}, {1 : 25,  26 : 50});
            levelThreeOtherBranch = containers.Map({'G1', 'G2', 'G3'}, {1 : 11,  12 : 22, 23: 25});
            
            leafGroupOne = containers.Map({0.01, 0.02}, {1 : 12, 13 : 25});
            leafGroupTwo = containers.Map({0.01, 0.02}, {26 : 35, 36 : 50});
            
            leafGroupThree = containers.Map({0.01, 0.02}, {1 : 5, 6 : 11});
            leafGroupFour = containers.Map({0.01, 0.02}, {12 : 17, 18 : 22});
            leafGroupFive = containers.Map({0.01, 0.02}, {[23, 24], 25});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.savedDataSets('LightStep_20') = entity.DataSet(1 : 50, 'none');
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(levelTwo, 'deviceStream')...
                .thenReturn(levelThree, 'groups')...
                .thenReturn(leafGroupOne, 'rstar')...
                .thenReturn(leafGroupTwo, 'rstar')...
                .thenReturn(levelThreeOtherBranch, 'groups')...
                .thenReturn(leafGroupThree, 'rstar')...
                .thenReturn(leafGroupFour, 'rstar')...
                .thenReturn(leafGroupFive, 'rstar');
            
            s = struct();
            s.type = 'complex-analysis';
            s.buildTreeBy = {'dataSet', 'deviceStream', 'epochgroups', 'rstar'};
            s.dataSet = 'LightStep_20';
            s.deviceStream = {'Amplifier_Ch1', 'Amplifier_Ch2'};
            s.epochgroups = {'G1', 'G2', 'G3'};
            s.rstar = {0.01, 0.02};
            
            template = core.AnalysisTemplate(s);
            offlineAnalysis = core.OfflineAnalysis('test-collective-analysis', mockedCellData);
            tree = offlineAnalysis.do(template);
            disp('analysis tree')
            tree.treefun(@(node) node.name).tostring()
                       
            leafs = tree.findleaves();
            obj.verifyEqual(tree.get(leafs(1)).epochIndices, leafGroupOne(0.01));
            obj.verifyEqual(tree.get(leafs(2)).epochIndices, leafGroupOne(0.02));
            
            obj.verifyEqual(tree.get(leafs(3)).epochIndices, leafGroupTwo(0.01));
            obj.verifyEqual(tree.get(leafs(4)).epochIndices, leafGroupTwo(0.02));
            
            obj.verifyEqual(tree.get(leafs(5)).epochIndices, leafGroupThree(0.01));
            obj.verifyEqual(tree.get(leafs(6)).epochIndices, leafGroupThree(0.02));
            
            obj.verifyEqual(tree.get(leafs(7)).epochIndices, leafGroupFour(0.01));
            obj.verifyEqual(tree.get(leafs(8)).epochIndices, leafGroupFour(0.02));
            
            obj.verifyEqual(tree.get(leafs(9)).epochIndices, leafGroupFive(0.01));
            obj.verifyEqual(tree.get(leafs(10)).epochIndices, leafGroupFive(0.02));
        end
    end
    
end
