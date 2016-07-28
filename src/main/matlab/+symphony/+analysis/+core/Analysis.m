classdef Analysis < handle
    
    properties(SetAccess = protected)
        featureExtractorContext
        nodeManager
    end
    
    methods
        
        function obj = Analysis(context, tree)
            if nargin < 2
                tree = tree();
            end
            import symphony.analysis.core.*;
            obj.nodeManager = NodeManager(tree);
            obj.featureExtractorContext = context;
        end
        
        function do(obj)
            obj.buildTree();
            obj.createFeatures();
        end
        
        
        function createFeatures(obj)
            context = obj.featureExtractorContext;
            splitParameters = context.keys;
            
            for i = 1 : numel(splitParameters)
                splitParameter = splitParameters{i};
                extractors = context(splitParameter);
                arrayfun(@(extractor) extractor.extract(splitParameter), extractors);
            end
        end
    end

    methods(Abstract)
        buildTree(obj)
        createFeature(obj, extractors, splitParameters)
    end
    
end

