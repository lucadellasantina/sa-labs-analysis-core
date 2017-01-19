classdef AnalaysisManager < handle
    
    events
        AnalysisStopped
    end
    
    properties
        dataService
        onlineAnalysisState
    end
    
    methods
        
        function obj = AnalaysisManager(dataService)
            obj.dataService = dataService;
        end
        
        function result = doOfflineAnalysis(obj, request)
            
            analysis = sa_labs.analysis.core.OfflineAnalysis();
            templates = request.getTemplates();
            
            for i = 1 : numel(templates)
                template = templates(i);
                analysis.init(template);
                t = analysis.service();
                obj.dataService.saveAnalysis(t, template);
                analysis.collect();
            end
            result = analysis.getResult();
        end
        
        function result = doOnlineAnalysis(obj, request)
            analysis = sa_labs.analysis.core.OnlineAnalysis();
            templates = request.getTemplates();
            
            for i = 1 : numel(templates)
                template = templates(i);
                if obj.onlineAnalysisState == AnalysisState.NOT_STARTED
                    analysis.init(template);
                end
                analysis.service();
            end
            
            obj.onlineAnalysisState = AnalysisState.STARTED;
        end
    end
end