classdef Session < handle
    
    properties (SetAccess = private)
        analysisDataService
        presets
    end
    
    properties (SetObservable)
        project
    end
    
    methods
        
        function obj = Session(presets, analysisDataService)
            obj.presets = presets;
            obj.analysisDataService = analysisDataService;
        end
        
    end
end

