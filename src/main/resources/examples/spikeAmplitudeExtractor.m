classdef spikeAmplitudeExtractor < symphony.analysis.core.FeatureExtractor
    
    properties
        processEpoch = true
    end
    
    
    methods
        
        function handleEpoch(obj, node, epoch)
            device = obj.nodeManager.getDevice(node);
            
            spikeTimes = util.getSpikes(epoch, device);
            [spikeAmplitude, averageWaveForm] = util.getSpikeAmplitudes(epoch, spikeTimes);
            
            node.getFeature(FeatureId.SPIKE_AMP.description).data = spikeAmplitude;
            node.getFeature(FeatureId.SPIKE_TIMES.description).data = spikeTimes;
            
            feature = node.getFeature(FeatureIdentifier.AVERAGE_WAVE_FORM);
            
            if isempty(feature.data)
                feature.data = zeros(1, 41);
            end
            feature.data = feature.data + length(spikeTimes) .* averageWaveForm;
        end
        
        function handleFeature(~, node)
            feature = node.getFeature(FeatureId.AVERAGE_WAVE_FORM.description);
            feature.data = feature.data/range(feature.data);
        end
    end
    
end

