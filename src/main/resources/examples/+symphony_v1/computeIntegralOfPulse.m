function computeIntegralOfPulse(extractor, featureGroup)
    epochMatrix = [featureGroup.getFeature('EPOCH').data];
    
    pre = featureGroup.getParameter('preTime');
    stim = featureGroup.getParameter('stimTime');
    tail = featureGroup.getParameter('tailTime');
    rate = featureGroup.getParameter('sampleRate');
    
    time = (pre + stim + tail) * rate * 10^-3; % in seconds;
    
end

