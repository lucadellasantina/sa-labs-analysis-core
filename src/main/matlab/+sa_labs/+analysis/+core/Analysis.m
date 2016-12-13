classdef Analysis < handle
    
    properties(SetAccess = protected)
        functionContext
        nodeManager
        extractor
    end
    
    properties(Access = private)
        templateCache
    end
    
    properties(Dependent)
        analysisTemplate
    end
    
    methods
        
        function obj = Analysis()
            obj.nodeManager = sa_labs.analysis.core.NodeManager();
        end
        
        function init(obj, analysisTemplate)
            obj.nodeManager.setRootName(analysisTemplate.type);
            obj.templateCache = analysisTemplate;
            
            obj.extractor = sa_labs.analysis.core.FeatureExtractor.create(analysisTemplate);
            obj.extractor.loadFeatureDescription(analysisTemplate.featureDescriptionFile);
            obj.extractor.nodeManager = obj.nodeManager;
            
            obj.setEpochStream();
        end
        
        function ds = service(obj)
            
            if isempty(obj.templateCache)
                error('analysisTemplate is not initiliazed');
            end
            
            obj.buildTree();
            obj.extractFeatures();
            ds = obj.nodeManager.dataStore;
        end
        
        function destroy(obj)
            obj.templateCache = [];
        end
        
        function r = getResult(obj)
            r = obj.nodeManager.dataStore;
        end
        
        function template = get.analysisTemplate(obj)
            template = obj.templateCache;
        end
    end
    
    methods(Access = protected)
        
        function extractFeatures(obj)
            parameters = obj.getSplitParameters();
            
            for i = numel(parameters) : -1 : 1
                parameter = parameters{i};
                functions = obj.analysisTemplate.getExtractorFunctions(parameter);
                nodes = obj.getNodes(parameter);
                
                if ~ isempty(nodes)
                    obj.extractor.delegate(functions, nodes);
                    obj.updateEpochParameters(nodes);
                end
            end
        end
    end
    
    methods(Access = protected, Abstract)
        buildTree(obj)
        getSplitParameters(obj)
        getNodes(obj, parameter)
        updateEpochParameters(obj, nodes)
    end
    
    methods(Abstract)
        setEpochStream(obj)
    end
    
end
