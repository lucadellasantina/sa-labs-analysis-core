classdef OfflineAnalysisTest < matlab.unittest.TestCase
    
    methods(Test)
        
        function testDoSimple(obj)
            import symphony.analysis.*;
            
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
            
            % Tree with two level and one branch - analysis
            levelTwoOtherBranch = containers.Map({'Amplifier_Ch1'}, {51 : 100});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.savedDataSets('LightStep_20') = entity.DataSet(1 : 50, 'none');
            mockedCellData.savedDataSets('LightStep_500') = entity.DataSet(51 : 100, 'none');
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(levelTwo, 'deviceStream')...
                .times(1).thenReturn(levelTwoOtherBranch, 'deviceStream');
            
            tree = testAnalyze();
            actual = tree.treefun(@(node) node.name);
            
            expected = {'test-analysis'; 'dataSet==LightStep_20'; 'deviceStream==Amplifier_Ch1'; 'dataSet==LightStep_500'; 'deviceStream==Amplifier_Ch1'};
            obj.verifyEqual(actual.Node, expected);
            
            % Tree with two level and two branch - analysis
            
            levelTwo = containers.Map({'Amplifier_Ch1', 'Amplifier_Ch2'}, {1 : 50, 1 : 50});
            levelTwoOtherBranch = containers.Map({'Amplifier_Ch1', 'Amplifier_Ch2'}, {51 : 100, 51 : 100});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.savedDataSets('LightStep_20') = entity.DataSet(1 : 50, 'none');
            mockedCellData.savedDataSets('LightStep_500') = entity.DataSet(51 : 100, 'none');
            mockedCellData.when.getEpochValuesMap(AnyArgs())...
                .thenReturn(levelTwo, 'deviceStream')...
                .times(1).thenReturn(levelTwo, 'deviceStream')...
                .times(2).thenReturn(levelTwoOtherBranch, 'deviceStream');
            
            tree = testAnalyze();
            actual = tree.treefun(@(node) node.name);
            
            expected = {'test-analysis'; 'dataSet==LightStep_20'; 'deviceStream==Amplifier_Ch1';'deviceStream==Amplifier_Ch2';...
                'dataSet==LightStep_500'; 'deviceStream==Amplifier_Ch1';'deviceStream==Amplifier_Ch2'};
            
            obj.verifyEqual(actual.Node, expected);
            
            function tree = testAnalyze()
                import symphony.analysis.*;
                
                template = core.AnalysisTemplate(structure);
                offlineAnalysis = core.OfflineAnalysis('test-collective-analysis', mockedCellData);
                tree = offlineAnalysis.do(template);
                disp('analysis tree')
                tree.treefun(@(node) node.name).tostring()
            end
        end
    end
    
end
