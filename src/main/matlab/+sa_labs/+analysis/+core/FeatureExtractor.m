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
    
    
    methods (Static)
        
        function featureExtractor = create(template)
            PARENT = 'sa_labs.analysis.core.FeatureExtractor';
            
            class = template.extractorClazz;
            constructor = str2func(class);
            featureExtractor = constructor();
            parentClasses = superclasses(featureExtractor);
            
            if ~ (isa(featureExtractor, PARENT) || numel(parentClasses) > 1 && strcmp(PARENT, parentClasses{end - 1}))
                error(['instance is not of type' PARENT]);
            end
        end
    end
end
