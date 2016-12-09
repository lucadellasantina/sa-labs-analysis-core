function extractSpikeFeatures(obj, node, varargin)

    stream = obj.getDefaultStream(node);

    ip = inputParser;
    ip.addParameter('spikeDetectorMode', 'mht.spike_util', @ischar);
    ip.addParameter('stream', stream, @ischar);
    ip.parse(varargin{:});

    mode = ip.Results.spikeDetectorMode;
    stream = ip.Results.stream;

    spikeUtil = sa_labs.common.SpikeUtil(mode);

    response = obj.getResponse(node, stream);
    features = spikeUtil.extractSpikes(response);
    node.appendFeature(features);

end

