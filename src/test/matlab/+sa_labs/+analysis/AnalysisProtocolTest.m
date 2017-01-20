classdef AnalysisProtocolTest < matlab.unittest.TestCase
    
    properties
        lightStepStructure
        standardAnalysis
    end
    
    methods
        function obj = AnalysisProtocolTest()
            fname = which('analysis.yaml');
            obj.lightStepStructure = yaml.ReadYaml(fname);
            fname = which('standard-analysis.yaml');
            obj.standardAnalysis = yaml.ReadYaml(fname);
        end
    end
    
    methods(Test)
        
        function testGetExtractorFunctions(obj)
            template = sa_labs.analysis.core.AnalysisProtocol(obj.lightStepStructure);
            expected = {'MeanExtractor', 'spikeAmplitudeExtractor'};
            obj.verifyEqual(template.getExtractorFunctions('rstarMean'), expected);
            obj.verifyEmpty(template.getExtractorFunctions('unknown'));
        end
        
        function testProperties(obj)
            template = sa_labs.analysis.core.AnalysisProtocol(obj.lightStepStructure);
            obj.verifyEqual(template.copyParameters, {'ndf', 'etc'});
            obj.verifyEqual(template.getSplitParameters(), {'EpochGroup', 'deviceStream', 'grpEpochs', 'rstarMean', 'epochId'});
        end
        
        function testTemplateTree(obj)
            template = struct();
            template.type = 'test-analysis';
            template.buildTreeBy = {'a', 'b, c, d', 'e, f', 'g, h, i'};
            template.extractorClass = 'sa_labs.analysis.core.FeatureExtractor';
            
            t = sa_labs.analysis.core.AnalysisProtocol(template);
            disp('Template tree for visual validation');
            t.displayTemplate();
            obj.verifyEqual(t.numberOfPaths(), 18);
            v = t.getSplitParametersByPath(1);
            obj.verifyEqual(v, {'a', 'b', 'e', 'g'});
            v = t.getSplitParametersByPath(18);
            obj.verifyEqual(v, {'a', 'd', 'f', 'i'});
        end
        
        function testValidateSplitValues(obj)
            template = sa_labs.analysis.core.AnalysisProtocol(obj.lightStepStructure);
            obj.verifyEmpty(template.getSplitValue('unkown'));
            
            values = template.validateSplitValues('EpochGroup', 'empty');
            obj.verifyEqual(values, {'empty'});
            
            values = template.validateSplitValues('deviceStream', 'Amplifier_ch1');
            obj.verifyEqual(values, {'Amplifier_ch1'});
            
            values = template.validateSplitValues('deviceStream', {'Amplifier_ch1', 'Amplifier_ch2'});
            obj.verifyEqual(values, {'Amplifier_ch1'});
            
            expected = {'G1', 'G3'};
            values = template.validateSplitValues('grpEpochs',  {'G0', 'G1', 'G3', 'G5'});
            obj.verifyEqual(values, expected);
            
            expected = {'G3'};
            values = template.validateSplitValues('grpEpochs',  'G3');
            obj.verifyEqual(values, expected);
            
            handle = @() template.validateSplitValues('grpEpochs',  {'unknown'});
            obj.verifyError(handle, sa_labs.analysis.app.Exceptions.SPLIT_VALUE_NOT_FOUND.msgId);
            
            values = template.validateSplitValues('rstarMean', 1:5);
            obj.verifyEqual(values, 1:5);
            
            values = template.validateSplitValues('epochId', 1:3);
            obj.verifyEqual(values, 1:3);
            
            handle = @()template.validateSplitValues('epochId', 6);
            obj.verifyError(handle, sa_labs.analysis.app.Exceptions.SPLIT_VALUE_NOT_FOUND.msgId);
            
            values = template.validateSplitValues('epochId', 2:3);
            obj.verifyEqual(values, 2:3);
        end
        
        function validateStandardAnalysis(obj)
            import sa_labs.analysis.*;
            
            template = core.AnalysisProtocol(obj.standardAnalysis);
            
            [p, v] = template.getSplitParameters();
            obj.verifyEqual(p, {'displayName', 'textureAngle', 'RstarMean', 'barAngle', 'curSpotSize'});
            obj.verifyEqual(v, [1, 2, 2, 2, 2]);
            
            obj.verifyEqual(4,  template.numberOfPaths());
            
            v = template.getSplitParametersByPath(4);
            obj.verifyEqual(v, {'displayName', 'curSpotSize'});
            
            fname = app.App.getResource(app.Constants.FEATURE_DESC_FILE_NAME);
            obj.verifyNotEmpty(template.featureDescriptionFile);
            obj.verifyEqual(template.featureDescriptionFile, fname);
        end
        
    end
    
end

