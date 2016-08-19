classdef OfflineAnalysisTest < matlab.unittest.TestCase
    
    methods(Test)
        
        function testDo(obj)
            import symphony.analysis.*;
            
            levelOne = containers.Map({'Amplifier_Ch1'}, {1:50});
            
            mockedCellData = Mock(entity.CellData());
            mockedCellData.savedDataSets('LightStep_20') = entity.DataSet(1 : 1 : 50, 'none');
            mockedCellData.when.getEpochValuesMap(AnyArgs()).thenReturn(levelOne, 'deviceStream');
            
            structure = struct();
            structure.analysis = 'test-analysis';
            structure.buildTreeBy = {'dataSet', 'deviceStream'};
            template = core.AnalysisTemplate(structure);
            
            offlineAnalysis = core.OfflineAnalysis('test-collective-analysis', mockedCellData);
            tree = offlineAnalysis.do(template);
            disp('tree')
            tree.treefun(@(node) node.name).tostring()
        end
    end
    
    
end
