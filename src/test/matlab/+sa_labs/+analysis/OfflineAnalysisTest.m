classdef OfflineAnalysisTest < matlab.unittest.TestCase
    
    methods(Test)
        
        function testBuildTreeSimple(obj)
            import sa_labs.analysis.*;
            
            levelOne = containers.Map({'LightStep_20'}, {1 : 50});
            levelTwo = containers.Map({'Amplifier_Ch1'}, {1 : 50});
            mockedCellData = Mock(entity.CellData());
            mockedCellData.when.getEpochValuesMap(AnyArgs()).thenReturn(levelOne, 'dataSet')...
                .thenReturn(levelTwo, 'deviceStream');
            
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
            % Tree with two level - analysis
            structure = struct();
            structure.type = 'test-analysis';
            structure.buildTreeBy = {'dataSet', 'deviceStream'};
            levelOne = containers.Map({'LightStep_20', 'LightStep_500'}, {1 : 50, 51 : 100});
            levelTwoOtherBranch = containers.Map({'Amplifier_Ch1'}, {51 : 100});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(levelOne, 'dataSet')...
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
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(levelOne, 'dataSet')...
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
            
            levelOne = containers.Map({'LightStep_20', 'LightStep_500'}, {1 : 50, 51 : 100});
            
            levelTwo = containers.Map({'Amplifier_Ch1', 'Amplifier_Ch2'}, {1 : 50,  1 : 25});
            levelThree = containers.Map({'G1', 'G2'}, {1 : 25,  26 : 50});
            levelThreeOtherBranch = containers.Map({'G1', 'G2', 'G3'}, {1 : 11,  12 : 22, 23: 25});
            
            leafGroupOne = containers.Map({0.01, 0.02}, {1 : 12, 13 : 25});
            leafGroupTwo = containers.Map({0.01, 0.02}, {26 : 35, 36 : 50});
            
            leafGroupThree = containers.Map({0.01, 0.02}, {1 : 5, 6 : 11});
            leafGroupFour = containers.Map({0.01, 0.02}, {12 : 17, 18 : 22});
            leafGroupFive = containers.Map({0.01, 0.02}, {[23, 24], 25});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(levelOne, 'dataSet')...
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
            s.dataSet.splitValue = 'LightStep_20';
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
        
        function testBuildTreeWithMultipleBranches(obj)
            import sa_labs.analysis.*;
            
            % analysis template structure
            s = struct();
            s.type = 'complex-analysis';
            s.buildTreeBy = {'protocol', 'textureAngle, barAngle, curSpotSize', 'RstarMean'};
            
            % mocked cell data
            protocols = containers.Map({'MovingBar', 'DriftingGrating', 'DrifitngTexture'}, {1 : 50, 51 : 100, 101: 150});
            
            % level two
            barAngle = containers.Map({10, 20, 30}, {1 : 15,  16 : 30, 31 : 50});
            driftingGratingAngle = containers.Map({10, 20, 30}, {51 : 65,  66 : 80, 81 : 100});
            driftingTextureAngle = containers.Map({10, 20, 30}, {101 : 115,  116 : 130, 131 : 150});
            
            % level three
            rstarMeanBarAngle10 = containers.Map({0.1, 0.2}, {1 : 10,  11 : 15});
            rstarMeanBarAngle20 = containers.Map({0.1, 0.2}, {16 : 20,  21 : 30});
            rstarMeanBarAngle30 = containers.Map({0.1, 0.2}, {31 : 35,  36 : 50});
            
            rstarMeanDriftingGratingAngle10 = containers.Map({0.5, 0.6}, {51 : 60,  61 : 65});
            rstarMeanDriftingGratingAngle20 = containers.Map({0.5, 0.6}, {66 : 86,  87 : 90});
            rstarMeanDriftingGratingAngle30 = containers.Map({0.5, 0.6}, {91 : 95,  96 : 100});
            
            rstarMeanDriftingTextureAngle10 = containers.Map({0.1, 0.2}, {101 : 110,  111 : 115});
            rstarMeanDriftingTextureAngle20 = containers.Map({0.1, 0.2}, {116 : 120,  121 : 130});
            rstarMeanDriftingTextureAngle30 = containers.Map({0.1, 0.2}, {131 : 135,  136 : 150});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(protocols, 'protocol')...
                .thenReturn(driftingTextureAngle, 'textureAngle')... % Drifting Texture
                .thenReturn(rstarMeanDriftingTextureAngle10, 'RstarMean')...
                .thenReturn(rstarMeanDriftingTextureAngle20, 'RstarMean')...
                .thenReturn(rstarMeanDriftingTextureAngle30, 'RstarMean')...
                .thenReturn(driftingGratingAngle, 'textureAngle')... % Drifting Grating
                .thenReturn(rstarMeanDriftingGratingAngle10, 'RstarMean')...
                .thenReturn(rstarMeanDriftingGratingAngle20, 'RstarMean')...
                .thenReturn(rstarMeanDriftingGratingAngle30, 'RstarMean')...
                .thenReturn(containers.Map(), 'textureAngle')... % MovingBar
                .thenReturn(protocols, 'protocol')...
                .thenReturn(containers.Map(), 'barAngle')...  % Drifting Texture
                .thenReturn(containers.Map(), 'barAngle')...  % Drifting Grating
                .thenReturn(barAngle, 'barAngle')...          % MovingBar
                .thenReturn(rstarMeanBarAngle10, 'RstarMean')...
                .thenReturn(rstarMeanBarAngle20, 'RstarMean')...
                .thenReturn(rstarMeanBarAngle30, 'RstarMean')...
                .thenReturn(protocols, 'protocol')...
                .thenReturn(containers.Map(), 'curSpotSize')... % Drifting Texture
                .thenReturn(containers.Map(), 'curSpotSize')... % Drifting Grating
                .thenReturn(containers.Map(), 'curSpotSize');   % MovingBar
            
            template = core.AnalysisTemplate(s);
            offlineAnalysis = core.OfflineAnalysis('test-collective-analysis', mockedCellData);
            tree = offlineAnalysis.do(template);
            disp('analysis tree')
            tree.treefun(@(node) node.name).tostring()
            
            leafs = tree.findleaves();
            
            obj.verifyEqual(tree.get(leafs(1)).epochIndices, rstarMeanDriftingTextureAngle10(0.1));
            obj.verifyEqual(tree.get(leafs(2)).epochIndices, rstarMeanDriftingTextureAngle10(0.2));
            
            obj.verifyEqual(tree.get(leafs(3)).epochIndices, rstarMeanDriftingTextureAngle20(0.1));
            obj.verifyEqual(tree.get(leafs(4)).epochIndices, rstarMeanDriftingTextureAngle20(0.2));
            
            obj.verifyEqual(tree.get(leafs(5)).epochIndices, rstarMeanDriftingTextureAngle30(0.1));
            obj.verifyEqual(tree.get(leafs(6)).epochIndices, rstarMeanDriftingTextureAngle30(0.2));
            
            obj.verifyEqual(tree.get(leafs(7)).epochIndices, rstarMeanDriftingGratingAngle10(0.5));
            obj.verifyEqual(tree.get(leafs(8)).epochIndices, rstarMeanDriftingGratingAngle10(0.6));
            
            obj.verifyEqual(tree.get(leafs(9)).epochIndices, rstarMeanDriftingGratingAngle20(0.5));
            obj.verifyEqual(tree.get(leafs(10)).epochIndices, rstarMeanDriftingGratingAngle20(0.6));
            
            obj.verifyEqual(tree.get(leafs(11)).epochIndices, rstarMeanDriftingGratingAngle30(0.5));
            obj.verifyEqual(tree.get(leafs(12)).epochIndices, rstarMeanDriftingGratingAngle30(0.6));
            
            obj.verifyEqual(tree.get(leafs(13)).epochIndices, rstarMeanBarAngle10(0.1));
            obj.verifyEqual(tree.get(leafs(14)).epochIndices, rstarMeanBarAngle10(0.2));
            
            obj.verifyEqual(tree.get(leafs(15)).epochIndices, rstarMeanBarAngle20(0.1));
            obj.verifyEqual(tree.get(leafs(16)).epochIndices, rstarMeanBarAngle20(0.2));
            
            obj.verifyEqual(tree.get(leafs(17)).epochIndices, rstarMeanBarAngle30(0.1));
            obj.verifyEqual(tree.get(leafs(18)).epochIndices, rstarMeanBarAngle30(0.2));
            
        end
    end
    
end
