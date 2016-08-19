classdef Analysis < handle
    
    properties(SetAccess = protected)
        functionContext
        nodeManager
        resultManager
        extractor
    end
    
    properties(Access = private)
        templateCache
    end
    
    properties(Dependent)
        result
        analysisTemplate
    end
    
    methods
        
        function obj = Analysis(name)
            
            import symphony.analysis.core.*;
            
            obj.resultManager = NodeManager(tree());
            obj.resultManager.setRootName(name);
            
            obj.nodeManager = NodeManager(tree());
            obj.extractor = symphony.analysis.core.FeatureExtractor();
            obj.extractor.nodeManager = obj.nodeManager;
            obj.setEpochIterator();
        end
        
        function tree = do(obj, analysisTemplate)
            obj.templateCache = analysisTemplate;
            obj.buildTree();
            obj.extractFeatures();
            tree = obj.nodeManager.tree;
            obj.resultManager.appendToRoot(tree);
            
            obj.templateCache = [];
        end
        
        function t = get.result(obj)
            t = obj.resultManager.tree;
        end
        
        function template = get.analysisTemplate(obj)
            template = obj.templateCache;
        end
    end
    
    methods(Access = private)
        
        function extractFeatures(obj)
            parameters = obj.analysisTemplate.splitParameters;
            
            for i = numel(parameters) : -1 : 1
                parameter = parameters{i};
                functions = obj.analysisTemplate.getExtractorFunctions(parameter);
                
                if ~ isempty(functions)
                    obj.extractor.delegate(functions, parameter);
                end
            end
        end
    end
    
    methods(Access = protected, Abstract)
        buildTree(obj)
        setEpochIterator(obj)
    end
    
end
