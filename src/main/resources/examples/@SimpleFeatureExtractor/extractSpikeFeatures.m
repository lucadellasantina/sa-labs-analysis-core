function extractSpikeFeatures(obj, node, varargin)

    stream = obj.getDefaultStream(node);

    ip = inputParser;
    ip.addParameter('spikeDetectorMode', 'mht.spike_util', @ischar);
    ip.addParameter('stream', stream, @ischar);
    ip.parse(varargin{:});

    mode = ip.Results.spikeDetectorMode;
    stream = ip.Results.stream;
    
    desc = obj.descriptionMap('SPIKE');
    desc.mode = mode;

    if isempty(obj.spikeUtil)
        obj.spikeUtil = sa_labs.common.SpikeUtil(desc);
    end

    response = obj.getResponse(node, stream);
    features = obj.spikeUtil.extractFeatures(response);
    node.appendFeature(features);
end

