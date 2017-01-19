classdef Analysis < handle
    
    properties (SetAccess = protected)
        functionContext
        featureManager
        extractor
    end
    
    properties (Access = private)
        templateCache
    end
    
    properties (Dependent)
        analysisTemplate
    end
    
    methods
        
        function obj = Analysis()
            obj.featureManager = sa_labs.analysis.core.FeatureTreeManager();
        end
        
        function init(obj, analysisTemplate)
            obj.featureManager.setRootName(analysisTemplate.type);
            obj.templateCache = analysisTemplate;
            
            obj.extractor = sa_labs.analysis.core.FeatureExtractor.create(analysisTemplate);
            obj.extractor.loadFeatureDescription(analysisTemplate.featureDescriptionFile);
            obj.extractor.featureManager = obj.featureManager;
        end
        
        function ds = service(obj)
            
            if isempty(obj.templateCache)
                error('analysisTemplate is not initiliazed');
            end
            obj.build();
            obj.extractFeatures();
            ds = obj.featureManager.dataStore;
        end
        
        function destroy(obj)
            obj.templateCache = [];
        end
        
        function r = getResult(obj)
            r = obj.featureManager.dataStore;
        end
        
        function template = get.analysisTemplate(obj)
            template = obj.templateCache;
        end
    end
    
    methods (Access = protected)
        
        function extractFeatures(obj)
            parameters = obj.getFilterParameters();
            
            for i = numel(parameters) : -1 : 1
                parameter = parameters{i};
                functions = obj.analysisTemplate.getExtractorFunctions(parameter);
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
    
    methods (Abstract)
        setEpochSource(obj)
    end
    
end
