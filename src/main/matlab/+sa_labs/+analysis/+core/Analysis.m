classdef Analysis < handle
    
    properties (SetAccess = protected)
        functionContext
        featureManager
        extractor
        state
    end
    
    properties (SetAccess = private)
        templateCache
        project
    end
    
    properties (Dependent)
        analysisProtocol
    end

    properties(Abstract)
        mode
    end
    
    methods
        
        function obj = Analysis(project)
            obj.featureManager = sa_labs.analysis.core.FeatureTreeManager();
            obj.state == sa_labs.analysis.app.AnalysisState.NOT_STARTED;
            obj.project = project;
        end
        
        function init(obj, analysisProtocol)
            obj.featureManager.setRootName(analysisProtocol.type);
            obj.templateCache = analysisProtocol;
            
            obj.extractor = sa_labs.analysis.core.FeatureExtractor.create(analysisProtocol);
            obj.extractor.loadFeatureDescription(analysisProtocol.featureDescriptionFile);
            obj.extractor.featureManager = obj.featureManager;
            obj.extractor.analysisMode = obj.mode;

            obj.state = sa_labs.analysis.app.AnalysisState.INITIALIZED;
        end
        
        function ds = service(obj)
            
            if isempty(obj.templateCache)
                error('analysisProtocol is not initiliazed');
            end

            obj.state == sa_labs.analysis.app.AnalysisState.STARTED;
            obj.build();
            obj.extractFeatures();
            ds = obj.featureManager.dataStore;
            obj.state == sa_labs.analysis.app.AnalysisState.COMPLETED;
        end
        
        function destroy(obj)
            obj.templateCache = [];
        end
        
        function r = getResult(obj)
            r = obj.featureManager.dataStore;
        end
        
        function template = get.analysisProtocol(obj)
            template = obj.templateCache;
        end

        function setEpochSource(obj)
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
end
