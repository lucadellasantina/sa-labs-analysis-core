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
            
            import sa_labs.analysis.core.*;
            
            obj.resultManager = NodeManager();
            obj.resultManager.setRootName(name);
            obj.nodeManager = NodeManager();
            
        end
        
        function init(obj, analysisTemplate)
            obj.nodeManager.setRootName(analysisTemplate.type);
            obj.templateCache = analysisTemplate;
            
            obj.extractor = sa_labs.analysis.core.FeatureExtractor.create(analysisTemplate);
            obj.setEpochIterator();
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
        
        function collect(obj, dataStores)
            if nargin < 2
                dataStores = obj.nodeManager.dataStore;
            end
            arrayfun(@(ds) obj.resultManager.append(ds), dataStores);
        end
        
        function destroy(obj)
            obj.templateCache = [];
        end

        function r = get.result(obj)
            r = obj.resultManager.dataStore;
        end
        
        function template = get.analysisTemplate(obj)
            template = obj.templateCache;
        end
    end
    
    methods(Access = protected)
        
        function extractFeatures(obj)
            parameters = obj.analysisTemplate.getSplitParameters();
            
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
