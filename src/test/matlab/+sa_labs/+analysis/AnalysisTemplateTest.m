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
            template = sa_labs.analysis.core.AnalysisTemplate(obj.lightStepStructure);
            expected = {'MeanExtractor', 'spikeAmplitudeExtractor'};
            obj.verifyEqual(template.getExtractorFunctions('rstarMean'), expected);
            obj.verifyEmpty(template.getExtractorFunctions('unknown'));
        end
        
        function testProperties(obj)
            template = sa_labs.analysis.core.AnalysisTemplate(obj.lightStepStructure);
            obj.verifyEqual(template.copyParameters, {'ndf', 'etc'});
            obj.verifyEqual(template.splitParameters, {'dataSet', 'deviceStream', 'grpEpochs', 'rstarMean', 'epochId'});
        end
        
        function testValidateSplitValues(obj)
            template = sa_labs.analysis.core.AnalysisTemplate(obj.lightStepStructure);
            obj.verifyEmpty(template.getSplitValue('unkown'));
            
            values = template.validateSplitValues('dataSet', 'empty');
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
        
    end
    
end

