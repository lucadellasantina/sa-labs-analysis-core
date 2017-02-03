function addEpochAsFeature(extractor, featureGroup, varargin)


ip = inputParser;
ip.addParameter('device', '', @ischar);
ip.parse(varargin{:});
device = ip.Results.device;

import sa_labs.analysis.*;
description = extractor.descriptionMap('EPOCH');
epochs = extractor.getEpochs(featureGroup);

if isempty(device)
    device = featureGroup.splitValue;
end

for epoch = epochs
    data = epoch.getResponse(device);
    epochFeature = entity.Feature(description, data.quantity);
    featureGroup.appendFeature(epochFeature);
end

end