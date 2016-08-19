classdef AnalysisTemplateTest < matlab.unittest.TestCase
    
    properties
        lightStepStructure
    end
    
    methods
        function obj = AnalysisTemplateTest()
            fname = which('light-step-analysis.yaml');
            obj.lightStepStructure = yaml.ReadYaml(fname);
        end
    end
    
    methods(Test)
        
        function getExtractorFunctions(obj)
            template = symphony.analysis.core.AnalysisTemplate(obj.lightStepStructure);
            expected = {'MeanExtractor', 'spikeAmplitudeExtractor'};
            obj.verifyEqual(template.getExtractorFunctions('rstarMean'), expected);
            obj.verifyEmpty(template.getExtractorFunctions('unknown'));
        end
        
        function testProperties(obj)
            template = symphony.analysis.core.AnalysisTemplate(obj.lightStepStructure);
            obj.verifyEqual(template.copyParameters, {'ndf', 'etc'});
            obj.verifyEqual(template.splitParameters, {'deviceStream', 'dataSet', 'grpEpochs', 'rstarMean', 'epochId'});
        end
        
        function testValidateLevel(obj)
            template = symphony.analysis.core.AnalysisTemplate(obj.lightStepStructure);
            obj.verifyEmpty(template.getSplitValue('unkown'));
            
            values = template.validateLevel(1, 'deviceStream', 'Amplifier_ch1');
            obj.verifyEqual(values, {'Amplifier_ch1'});
            
            values = template.validateLevel(1, 'deviceStream', {'Amplifier_ch1', 'Amplifier_ch2'});
            obj.verifyEqual(values, {'Amplifier_ch1'});
            
            values = template.validateLevel(2, 'dataSet', 'empty');
            obj.verifyEqual(values, {'empty'});
            
            expected = {'G1', 'G3'};
            values = template.validateLevel(3, 'grpEpochs',  {'G0', 'G1', 'G3', 'G5'});
            obj.verifyEqual(values, expected);
            
            expected = {'G3'};
            values = template.validateLevel(3, 'grpEpochs',  'G3');
            obj.verifyEqual(values, expected);
            
            handle = @() template.validateLevel(3, 'grpEpochs',  {'unknown'});
            obj.verifyError(handle, symphony.analysis.app.Exceptions.SPLIT_VALUE_NOT_FOUND.msgId);
            
            values = template.validateLevel(4, 'rstarMean', 1:5);
            obj.verifyEqual(values, 1:5);
            
            values = template.validateLevel(5, 'epochId', 1:3);
            obj.verifyEqual(values, 1:3);
            
            handle = @()template.validateLevel(5, 'epochId', 6);
            obj.verifyError(handle, symphony.analysis.app.Exceptions.SPLIT_VALUE_NOT_FOUND.msgId);
            
            values = template.validateLevel(5, 'epochId', 2:3);
            obj.verifyEqual(values, 2:3);
        end
        
    end
    
end

