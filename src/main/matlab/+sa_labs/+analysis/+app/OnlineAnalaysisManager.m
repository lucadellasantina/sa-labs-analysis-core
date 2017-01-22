classdef OnlineAnalaysisManager < sa_labs.analysis.core.FigureHandlerManager
    
    events
        AnalysisStopped
    end
    
    properties (Access = private)
        analysisQueue
        recordingLabel
    end

    properties (Access = private)
        analysisMap
    end 
    
    methods
        
        function obj = OnlineAnalaysisManager(documentationService)
          obj.analysisMap = containers.Map();    
          obj.documentationService = documentationService;

          obj.addlistener(documentationService, 'BeganEpochGroup', @(h,d) obj.onServiceBeganEpochGroup())
          obj.addlistener(documentationService, 'EndedEpochGroup', @(h,d) obj.onServiceEndedEpochGroup())
        end

        function updateQueue(obj, queue)
            obj.analysisQueue = queue;
        end

        function onServiceBeganEpochGroup(obj, ~, event)
            obj.recordingLabel = event.data.label;
        end

        function onServiceEndedEpochGroup(obj, ~, ~)
            obj.recordingLabel = '';
        end
            
        function addOnlineAnalysis(obj)
            import sa_labs.analysis.*;
            
            if isempty(obj.recordingLabel)
                obj.recordingLabel = char(datetime);
            end
            protocols = obj.analysisQueue.getActiveProtocols();

            for j = 1 : numel(protocols)
                protocol = protocols(j);
                analysis = core.OnlineAnalysis(protocol, obj.recordingLabel);
            end
            obj.analysisMap(analysis.identifier) = analysis;
        end

        function updateFigures(obj, epochOrInterval)

            obj.updateAnalysis(epochOrInterval);

            for i = 1:numel(obj.figureHandlers)
                obj.figureHandlers{i}.handleEpochOrInterval(epochOrInterval);
                obj.figureHandlers{i}.handleFeature(obj.analysis.featureManager);
            end
        end
    end

    methods (Access = private)

        function updateAnalysis(obj, epochSource)
            
            if isempty(obj.recordingLabel)
               obj.addOnlineAnalysis();
            end
            identifiers = strcat(type, obj.recordingLabel);
            keys = obj.analysisMap.keys;

            for i = find(ismember(keys, identifiers));
                analysis = obj.analysisContext(keys{i});
                analysis.setEpochSource(epochSource);
                analysis.service();
            end
        end  
    end
end