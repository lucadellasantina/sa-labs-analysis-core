classdef SpikeExtractor < sa_labs.analysis.core.FeatureExtractor
    
    properties
        shouldProcessEpoch = true
    end
    
    
    methods
        
        function handleEpoch(obj, node, epoch)
            device = obj.nodeManager.getDevice(node);
            
            spikeTimes = util.getSpikes(epoch, device);
            [spikeAmplitude, averageWaveForm] = util.getSpikeAmplitudes(epoch, spikeTimes);
            
            node.getFeature(FeatureId.SPIKE_AMP.description).data = spikeAmplitude;
            node.getFeature(FeatureId.SPIKE_TIMES.description).data = spikeTimes;
            
            data = length(spikeTimes) .* averageWaveForm;
            acrossEpochFeature = node.getFeature(FeatureId.AVERAGE_WAVE_FORM.description);
            acrossEpochFeature.add(data);
        end
        
        function handleFeature(~, node)
            node.getFeature(FeatureId.AVERAGE_WAVE_FORM.description).divideBy(@range);
        end
    end
    
end

