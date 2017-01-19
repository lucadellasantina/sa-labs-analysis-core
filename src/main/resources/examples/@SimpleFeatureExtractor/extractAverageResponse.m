function extractAverageResponse(obj, node, varargin)
    stream = obj.getDefaultStream(node);

    ip = inputParser;
    ip.addParameter('stream', stream, @ischar);
    ip.parse(varargin{:});
    
    node.appendFeature(?sa_labs.analysis.entity.Feature, 'unknown');
    response = obj.getResponse(node, stream);
end

