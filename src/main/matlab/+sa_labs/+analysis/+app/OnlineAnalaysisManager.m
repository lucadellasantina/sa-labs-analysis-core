classdef OnlineAnalaysisManager < handle
    
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
        
        function obj = OnlineAnalaysisManager()
          obj.analysisMap = containers.Map();    
        end

        function updateQueue(obj, queue)
            obj.analysisQueue = queue;
        end

        function setRecordingLabel(obj, label)
            obj.recordingLabel = label;
        end
            
        function createNewAnalysis(obj)
            import sa_labs.analysis.*;
            
            if ~ obj.isVaildRecordingLabel()
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
                %TODO handle feature manager
                obj.figureHandlers{i}.handleFeature(obj.analysis);
            end
        end

        function tf = isVaildRecordingLabel(obj)
            tf = ~ isempty(obj.recordingLabel) && any(strmatch(obj.recordingLabel, obj.analysisMap.keys));
        end  
    end

    methods (Access = private)

        function updateAnalysis(obj, epochSource)
            
            if ~ obj.isVaildRecordingLabel(obj.recordingLabel)
               obj.createNewAnalysis();
            end
            
            type = obj.analysisQueue.getActiveProtocolsType();
            identifiers = strcat(type, obj.recordingLabel);
            keys = obj.analysisMap.keys;

            for i = find(ismember(keys, identifiers))
                analysis = obj.analysisContext(keys{i});
                analysis.setEpochSource(epochSource);
                analysis.service();
            end
        end
    end
end