classdef ParserTest < matlab.unittest.TestCase
    
    properties
        skipTest = false
        skipMessage
        path
    end
    
    properties(Constant)
        SYMPHONY_V1_FILE = '061915Ac4.h5'
        SYMPHONY_V2_FILE = '060716c1.h5'
    end
    
    methods (TestClassSetup)
        function setSkipTest(obj)
            obj.path = [fileparts(which('test.m')) filesep 'fixtures' filesep 'parser' filesep];
            if ~ exist([obj.path obj.SYMPHONY_V1_FILE], 'file') && ~ exist([obj.path obj.SYMPHONY_V2_FILE], 'file')
                obj.skipTest = true;
                obj.skipMessage = (['Skipping ' class(obj) ' '...
                    obj.SYMPHONY_V1_FILE ' and ' obj.SYMPHONY_V2_FILE...
                    ' are not found in matlab path']);
            end
        end
    end
    
    methods(Test)
        
        function testGetInstance(obj)
            if(obj.skipTest)
                return;
            end
            import symphony.analysis.*;
            
            ref = parser.getInstance([obj.path obj.SYMPHONY_V1_FILE]);
            obj.verifyClass(ref, ?symphony.analysis.parser.DefaultSymphonyParser);
            %data = ref.parse();
           ref = parser.getInstance([obj.path obj.SYMPHONY_V2_FILE]);
            obj.verifyClass(ref, ?symphony.analysis.parser.Symphony2Parser);
        end
    end
end

