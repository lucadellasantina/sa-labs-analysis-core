classdef FeatureBuilder < handle
    
    properties
        nodeManager
        epochHandler
    end
    
    methods
        
        function build(obj, parameter)
        	%	
        	%
        	% Performance considerations 	
        	%	order(n) for online analysis
        	% 	order(n^2) for offline analysis
            
            nodes = obj.nodeManager.findBySplitParameter(parameter);
            for i = 1 : numel(nodes)
                node = nodes(i);
                n = numel(node.epochIndices);
                
                if obj.processEpoch
                    arrayfun(@(index) obj.buildFeatures(node,...
                        obj.epochHandler(index, node.getDevice())), 1 : n);
                end
                obj.summarize(node);
            end
        end
        
        function tf = processEpoch(obj, node)
            tf = obj.nodeManager.isLeaf(node);
        end
    end
    
    methods(Abstract)
        buildFeatures(obj, node, epoch)
        summarize(obj, node)
    end
end

