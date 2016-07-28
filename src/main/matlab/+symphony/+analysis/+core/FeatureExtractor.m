classdef FeatureExtractor < handle
    
    properties
        nodeManager
        epochHandler
    end
    
    properties(Abstract)
        processEpoch
    end
    
    methods
        
        function extract(obj, parameter)
            
            % Performance considerations
            %	order(n) for online analysis
            % 	order(n^2) for offline analysis
            
            nodes = obj.nodeManager.findBySplitParameter(parameter);
            for i = 1 : numel(nodes)
                node = nodes(i);
                n = numel(node.epochIndices);
                
                if obj.processEpoch
                    arrayfun(@(index) obj.extractFromEpoch(node,...
                        obj.epochHandler(index)), 1 : n);
                end
            end
            obj.extractFromFeature(obj, node);
        end
        
        function handleEpoch(obj, node, epoch) %#ok <MANU>
        end
        
        function handleFeature(obj, node) %#ok <MANU>
        end
    end
    
end
