function addEpochAsFeature(analysis, featureGroup, varargin)

ip = inputParser;
ip.addParameter('device', '', @ischar);
ip.parse(varargin{:});
device = ip.Results.device;

import sa_labs.analysis.*;

if isempty(device)
    device = featureGroup.splitValue;
end

for epoch = analysis.getEpochs(featureGroup)
    data = @() epoch.getResponse(device).quantity;
    featureGroup.createFeature('EPOCH', data);
end
featureGroup.createFeature('EPOCH_AVERAGE',  mean(featureGroup.getFeatureData('EPOCH'), 2));
end