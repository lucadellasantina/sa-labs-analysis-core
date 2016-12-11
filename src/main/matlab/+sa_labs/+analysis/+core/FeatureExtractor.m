classdef FeatureExtractor < handle
    
    properties
        nodeManager
        epochStream
    end
    
    properties(Constant)
         CLASS = 'sa_labs.analysis.core.FeatureExtractor';
    end
    
    methods
        
        function delegate(obj, extractorFunctions, nodes)

            for i = 1 : numel(extractorFunctions)
                func = str2func(extractorFunctions{i});
                
                arrayfun(@(node) func(obj, node), nodes)
                featureKeySet = nodes.getFeatureKey();
                obj.nodeManager.percolateUp([nodes.id], featureKeySet, featureKeySet);
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
                epochs = obj.epochStream();
                return
            end
            % If the epoch Indices are not present in the dataset it will
            % throw an error
            epochs = obj.epochStream(node.epochIndices);
        end
    end
    
    
    methods (Static)
        
        function featureExtractor = create(template)
           
            import sa_labs.analysis.*; 
            parentClass =  core.FeatureExtractor.CLASS;
            class = template.extractorClazz;
            constructor = str2func(class);
            featureExtractor = constructor();
            parentClasses = superclasses(featureExtractor);
            
            if ~ (isa(featureExtractor, parentClass) || numel(parentClasses) > 1 && strcmp(parentClass, parentClasses{end - 1}))
                throw(app.Exceptions.MISMATCHED_EXTRACTOR_TYPE.create());
            end
        end
    end
end
