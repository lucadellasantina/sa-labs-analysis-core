classdef FeatureExtractor < handle
    
    properties
        nodeManager
        epochIterator
    end
    
    methods
        
        function delegate(obj, extractorFunctions, parameter)
            
            for i = 1 : numel(extractorFunctions)
                func = str2func(extractorFunctions{i});
                [nodes, ids] = obj.nodeManager.findNodesByName(parameter);
                arrayfun(@(node) func(obj, node), nodes)
                featureKeySet = nodes.getFeatureKey();
                obj.nodeManager.percolateUp(ids, featureKeySet, featureKeySet);
            end
        end
        
        function response = getResponse(obj, node, stream)
            
            epochs = obj.getEpochs(node);
            n = numel(epochs);
            data = epochs(1).getResponse(stream);
            response = zeros(n, numel(data));
            
            response(1, :) = data;
            for i = 2 : n
                data = epochs(i).getResponse(stream);
                response(i, :) = data;
            end
        end
        
        function epochs = getEpochs(obj, node)
            
            if isempty(node.epochIndices)
                epochs = obj.epochIterator();
                return
            end
            % If the epoch Indices are not present in the dataset it will
            % throw an error
            epochs = obj.epochIterator(node.epochIndices);
        end
    end
end
