classdef Analysis < handle
    
    properties(SetAccess = protected)
        featureBuilderContext
        nodeManager
    end
    
    methods
        
        function obj = Analysis(context, tree)
            if nargin < 2
                tree = tree();
            end
            obj.nodeManager = NodeManager(tree);
            obj.featureBuilderContext = context;
        end
        
        function do(obj)
            obj.buildTree();
            obj.createFeatures();
        end
        
        
        function createFeatures(obj)
            context = obj.featureBuilderContext;
            splitParameters = context.keys;
            
            for i = 1 : numel(splitParameters)
                splitParameter = splitParameters{i};
                builders = context(splitParameters);
                arrayfun(@(builder) builder.build(splitParameter), builders);
            end
        end
    end

    methods(Abstract)
        buildTree(obj)
        createFeature(obj, builders, splitParameters)
    end
    
end

