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
            obj.setEpochStream();
            obj.extractor.nodeManager = obj.nodeManager;
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
                
                if ~ isempty(functions)
                    obj.extractor.delegate(functions, obj.getNodes(parameter));
                end
            end
        end
    end
    
    methods(Access = protected, Abstract)
        buildTree(obj)
        getSplitParameters(obj)
        getNodes(obj, parameter)
    end
    
    methods(Abstract)
        setEpochStream(obj)
    end
    
end
