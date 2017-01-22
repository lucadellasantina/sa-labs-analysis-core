classdef Analysis < handle
    
    properties (SetAccess = protected)
        identifier
        functionContext
        featureManager
        extractor
        state
    end
    
    properties
        analysisProtocol
    end

    properties(Abstract)
        mode
    end
    
    methods
        
        function obj = Analysis(analysisProtocol, recordingLabel)
            obj.identifier = strcat(analysisProtocol.type, '-', recordingLabel);
            obj.analysisProtocol = analysisProtocol;
            obj.init();
        end

        function service(obj)
            
            if isempty(obj.analysisProtocol)
                error('analysisProtocol is empty'); %TODO replace with exception
            end
            obj.state = sa_labs.analysis.app.AnalysisState.STARTED;
            obj.build();
            obj.extractFeatures();
            obj.state = sa_labs.analysis.app.AnalysisState.COMPLETED;
        end
        
        function r = getResult(obj)
            r = obj.featureManager.dataStore;
        end

        function setEpochSource(obj, source) %#ok
            % will be overriden in the subclass
        end
    end
    
    methods (Access = protected)
        
        function extractFeatures(obj)
            parameters = obj.getFilterParameters();
            
            for i = numel(parameters) : -1 : 1
                parameter = parameters{i};
                functions = obj.analysisProtocol.getExtractorFunctions(parameter);
                nodes = obj.getFeatureGroups(parameter);
                
                if ~ isempty(nodes)
                    obj.extractor.delegate(functions, nodes);
                    obj.copyEpochParameters(nodes);
                end
            end
        end
    end
    
    methods (Access = protected, Abstract)
        build(obj)
        copyEpochParameters(obj, nodes)
        getFilterParameters(obj)
        getFeatureGroups(obj, parameter)
    end

    methods (Access = private)

        function init(obj)
            import sa_labs.analysis.*;
            protocol = obj.analysisProtocol;
            obj.state = app.AnalysisState.NOT_STARTED;
            
            obj.featureManager = core.FeatureTreeManager();
            obj.featureManager.setRootName(protocol.type);

            obj.extractor = core.FeatureExtractor.create(protocol);
            obj.extractor.loadFeatureDescription(protocol.featureDescriptionFile);
            obj.extractor.featureManager = obj.featureManager;
            obj.extractor.analysisMode = obj.mode;

            obj.state = app.AnalysisState.INITIALIZED;
        end
    end
end
