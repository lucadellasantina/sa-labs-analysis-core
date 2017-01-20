classdef AnalaysisManager < sa_labs.analysis.core.FigureHandlerManager
    
    events
        AnalysisStopped
    end
    
    properties
        dataService
        onlineAnalysisState
    end

    properties (Access = private)
        onlineAnalysis
        offlineAnalysis
    end 
    
    methods
        
        function obj = AnalaysisManager(dataService)
            obj.dataService = dataService;
            obj.offlineAnalysis = sa_labs.analysis.core.OfflineAnalysis();
            obj.onlineAnalysis = sa_labs.analysis.core.OnlineAnalysis();
        end
        
        function result = doOfflineAnalysis(obj, request)
            
            analysis = obj.offlineAnalysis;
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
        
        function result = beginOnlineAnalysis(obj, request)
            analysis = obj.OnlineAnalysis;
            templates = request.getTemplates();
            
            for i = 1 : numel(templates)
                template = templates(i);
                if obj.onlineAnalysisState == AnalysisState.NOT_STARTED
                    analysis.init(template);
                end
            end
            
            obj.onlineAnalysisState = AnalysisState.STARTED;
        end
        
        function updateFigures(obj, epochOrInterval)
            analysis = obj.OnlineAnalysis;
            analysis.setEpochSource(epochOrInterval);
            analysis.service();

            for i = 1:numel(obj.figureHandlers)
                obj.figureHandlers{i}.handleEpochOrInterval(analysis.nodeId, analysis.featureManager);
            end
        end
    end
end