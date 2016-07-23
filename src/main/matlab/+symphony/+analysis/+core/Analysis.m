classdef Analysis < handle

    properties(SetAccess = private)
        configurationStruct
        cellData
    end
    
    properties(SetAccess = private, GetAccess = protected)
        treeBuilder
    end
    
    properties(Dependent)
        tree
    end
    
    methods

        function obj = Analysis(config, data, tree)
            if nargin < 2
                tree = tree();
            end
            obj.cellData = data;
            obj.configurationStruct = config;
            obj.treeBuilder = core.AnalysisTreeBuilder(tree);
        end
        
        function doAnalysis(obj)
            obj.build();
            obj.extract();
            obj.organize();
        end
        
        function tree = get.tree(obj)
            tree= obj.treeBuilder.tree;
        end
    end
    
    methods(Access = protected)
        
        function build(obj)
        end
        
        function extract(obj)
            % iterate through config feature extractor 
            % and extract features
             features = featureExtractor.extract(obj.cellData);
             obj.addFeatures(features);
        end
        
        function organize(obj)
        end
    end
    
    methods(Access = private)
        function addFeatures(obj, features)
        end
    end
end

