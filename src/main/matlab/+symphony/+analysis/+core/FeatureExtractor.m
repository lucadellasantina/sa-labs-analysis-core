classdef FeatureExtractor < handle
    
    properties
        nodeManager
        epochIterator    %TODO rename
    end
    
    properties(Abstract)
        shouldProcessEpoch
    end
    
    methods
        
        function extract(obj, parameter)
            
            % Performance considerations
            %	order(n) for online analysis
            % 	order(n^2) for offline analysis
            
            nodes = obj.nodeManager.findNodesByName(parameter);
            for i = 1 : numel(nodes)
                node = nodes(i);
                n = numel(node.epochIndices);
                
                if obj.shouldProcessEpoch
                    arrayfun(@(index) obj.handleEpoch(node,...
                        obj.epochIterator(index)), 1 : n);
                end
            end
            obj.handleFeature(obj, node);
        end
        
        function handleEpoch(obj, node, epoch) %#ok <MANU>
        end
        
        function handleFeature(obj, node) %#ok <MANU>
        end
    end
    
end
