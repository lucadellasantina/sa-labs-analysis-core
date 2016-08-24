classdef FeatureExtractor < handle
    
    properties
        nodeManager
        epochIterator
    end
    
    methods
        
        function delegate(obj, extractorFunctions, parameter)
            
            for i = 1 : numel(extractorFunctions)
                func = str2func(extractorFunctions(i));
                nodes = obj.nodeManager.findNodesByName(parameter);
                arrayfun(@(node) func(obj, node, 'parameter', parameter), nodes)
            end
        end
        
        function epoch = getEpoch(obj, index)
            epoch = obj.epochIterator(index);
        end
    end
end
