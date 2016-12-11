classdef OnlineAnalysisTest < matlab.unittest.TestCase
    
    properties
    end
    
    methods(Test)
        
        function testBuildTreeSimple(obj)
            import sa_labs.analysis.*;
            
            structure = struct();
            structure.type = 'test-analysis';
            structure.buildTreeBy = {'stimTime', 'rstar'};
            structure.extractorClass = 'sa_labs.analysis.core.FeatureExtractor';
            
            epoch = struct();
            parameterKey = {'preTime', 'stimTime', 'tailTime', 'chan1', 'rstar'};
            
            template = core.AnalysisTemplate(structure);
            analysis = core.OnlineAnalysis();
            analysis.init(template)
            
            for i = 1 : 10
                epoch.parameters = containers.Map(parameterKey, {300, 20, 500, 'Amp1', i * 100});
                analysis.setEpochStream(epoch)
                tree = analysis.service();
                obj.verifyEqual(tree.nnodes, 2 + i);
            end
            
            tree = analysis.getResult();
            disp('analysis tree')
            tree.treefun(@(node) node.name).tostring()
            
            % interleaved epochs with stim time of 500
            for i = 1 : 10
                stimTime = 20;
                
                if mod(i, 5) == 0
                    stimTime = 500;
                end
                epoch.parameters = containers.Map(parameterKey, {300, stimTime, 500, 'Amp1', i * 100});
                analysis.setEpochStream(epoch)
                analysis.service();
            end
            
            tree = analysis.getResult();
            nodes = core.NodeManager(tree).getImmediateChildrensByName('stimTime==500');
            expected = tree.findleaves();
            
            disp('analysis tree')
            tree.treefun(@(node) node.name).tostring()
            
            obj.verifyEqual(numel(nodes), 2)
            obj.verifyEqual(nodes(1).id, expected(end - 1));
            obj.verifyEqual(nodes(2).id, expected(end));
        end
    end
end
