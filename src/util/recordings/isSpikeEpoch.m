function v = isSpikeEpoch(epoch, streamName)
v = false;
if strcmp(streamName, AnalysisConstant.AMP_CH_ONE)
    if strcmp(epoch.get('ampMode'), 'Cell attached')
        v = true;
    elseif strcmp(epoch.get('amplifierMode'), 'IClamp') %current clamp recording might have spikes
        v = true;
    end
elseif strcmp(obj.streamName, AnalysisConstant.AMP_CH_TWO)
    if strcmp(epoch.get('amp2Mode'), 'Cell attached')
        v = true;
    elseif strcmp(epoch.get('amplifier2Mode'), 'IClamp') %TODO: Is this recorded correctly in Symphony? I don't think so
        v = true;
    end
else
    disp(['Error in isSpikeEpoch: unknown stream name ' streamName]);
end