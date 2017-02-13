function duration = getStimulusDuration(featureGroup, varargin)

ip = inputParser;
ip.addParameter('relativeToStart', false, @islogical);
ip.addParameter('stimulusUnits', 'ms', @ischar);
ip.parse(varargin{:});
relativeToStart = ip.Results.relativeToStart;
stimulusUnits = ip.Results.stimulusUnits;

switch stimulusUnits
    case 'ms'
        factor = 10^-3;
end

pre = featureGroup.getParameter('preTime');
stimTime = featureGroup.getParameter('stimTime');
tail = featureGroup.getParameter('tailTime');
rate = featureGroup.getParameter('sampleRate');
dt = 1/rate;
duration = dt : dt : (pre + stimTime + tail) * factor; % in seconds

if relativeToStart
    duration = duration - pre * factor;
end
end

