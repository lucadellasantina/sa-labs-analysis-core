function computeIntegralOfPulse(analysis, featureGroup, varargin)

import  symphony_v1.extractorFunctions.*;

duration = util.getStimulusDuration(featureGroup, 'relativeToStart', true);
stimTime = featureGroup.getParameter('stimTime') * 10^-3;

epochAverage = featureGroup.getFeatureData('EPOCH_AVERAGE');
responseAverage = @() epochAverage(duration > 0 & duration <= stimTime, :);
featureGroup.createFeature('TIME_INTEGRAL', @() trapz(responseAverage()));

end
