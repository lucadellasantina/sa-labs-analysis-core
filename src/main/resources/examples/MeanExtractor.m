classdef MeanExtractor < sa_labs.analysis.core.FeatureExtractor
    
    properties
        description = FeatureId.MEAN_RESPONSE.description
        shouldProcessEpoch = true
    end
    
    methods
        
        function handleEpoch(obj, node, epoch)

            device = obj.nodeManager.getDevice(node);
            response = epoch.response(device);
            acrossEpochFeature = node.getFeature(obj.description);
            acrossEpochFeature.mean(response);
        end
        
        function handleFeature(obj)
            
        end
    end
end