classdef AnalysisConstant < handle
    
    properties(Constant)
        AMP_CH_ONE = 'Amp1'
        AMP_CH_TWO = 'Amp2'
        AMP_CH_THREE = 'Amp3'
        AMP_CH_FOUR = 'Amp4'
        AMP_CH_ONE_MODE = 'ampMode'
        AMP_CH_TWO_MODE = 'amp2Mode'
        AMP_CH_THREE_MODE = 'amp3Mode'
        AMP_CH_FOUR_MODE = 'amp4Mode'
        AMP_MODE_CELL_ATTACHED = 'Cell attached'
        
        H5_EPOCH_START_TIME = 'startTimeDotNetDateTimeOffsetUTCTicks'
        EPOCH_START_TIME = 'epochStartTime'
        EPOCH_NUMBER = 'epochNum'
        TOTAL_EPOCHS = 'Nepochs'
        EPOCH_IDENTIFIER = 'identifier'
        NUMBER_OF_AVERAGES = 'numberOfAverages'
        SAMPLE_RATE = 'sampleRate'
        STIM_TIME = 'stimTime'
        PRE_TIME = 'preTime'
        
        SPIKE_DETECTION_STD_DEV = 'Stdev'
        SPIKE_DETECTION_SIMPLE_THRESHOLD = 'Simple threshold'
        SPIKES_CH_ONE = 'spikes_ch1'
        SPIKES_CH_TWO = 'spikes_ch2'
    end
    
end

