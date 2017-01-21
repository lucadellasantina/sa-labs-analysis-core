classdef AnalaysisManager < sa_labs.analysis.core.FigureHandlerManager & mdepin.Bean
    
    events
        AnalysisStopped
    end
    
    properties
        dataService
        analysisModeDescription
    end

    properties (Access = private)
        analysisContext
    end 
    
    methods
        
        function obj = AnalaysisManager(config)
          obj = obj@mdepin.Bean(config);
        end
        
        function response = performAnalysis(obj, request)
            import sa_labs.analysis.*;
            
            project = obj.dataService.initializeProject(request.projectName);
            protocols = request.getAnalysisProtocols();
            obj.analysisContext = containers.Map();     

            for i = 1 : numel(protocols)
                protocol = protocols(i);
                analysis = obj.createAnalysisInstance();

                if analysis.state == app.AnalysisState.NOT_STARTED
                    analysis.init(protocol, project.getExperimentData());
                end
                analysis.service();
                obj.analysisContext(obj.protocol.type) = analysis;
            end
        end

        function updateEpochAndService(epochSource)
            protocols = obj.analysisContext.keys;
            
            for i = 1 : numel(protocols)
                analysis = obj.analysisContext(protocols{i})
                analysis.setEpochSource(epochSource);
                analysis.service();
            end
        end
      
        function updateFigures(obj, epochOrInterval)
            obj.updateEpochAndService(epochOrInterval);

            for i = 1:numel(obj.figureHandlers)
                obj.figureHandlers{i}.handleEpochOrInterval(epochOrInterval);
                obj.figureHandlers{i}.handleFeature(obj.analysis.featureManager);
            end
        end
    end

    methods (Access = private)

        function analysis = createAnalysisInstance(obj)
            import sa_labs.analysis.core.*;
            mode = AnalysisMode.getInstace(obj.analysisModeDescription);
            
            if mode.isOnline()
                analysis = OnlineAnalysis();
            else
                analysis = OffineAnalysis();
            end
        end
    end
end