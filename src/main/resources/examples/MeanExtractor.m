classdef MeanExtractor < symphony.analysis.core.FeatureExtractor
    
    properties
        description = FeatureDescriptionEnum.MEAN_RESPONSE
        processEpoch = true
    end
    
    methods
        
        function handleEpoch(obj, node, epoch)
            
            device = obj.nodeManager.getDevice(node);
            response = epoch.response(device);
            feature = node.getFeature(obj.description);
            feature.mean(response);
        end
        
        function handleFeature(obj, node) 
            node.addPlotHandles(obj.description, @(axes) obj.plotMeanFigure(node, axes))
        end
        
        function plotMeanFigure(obj, node, axes)
            feature = node.getFeatures(obj.description);
            y = feature.data;
            x = node.get('epochTime');
            plot(axes, x, y);
        end
    end
end