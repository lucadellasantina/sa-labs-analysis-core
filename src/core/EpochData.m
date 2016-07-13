classdef EpochData < handle
    
    properties
        attributes      % Map holding protocol and epoch attributes from h5 data 
        parentCell      % parent cell
    end
    
    properties (Hidden)
        dataLinks       % Map with keys as Amplifier device and values as responses 
    end
    
    methods
        
        function loadParams(obj, h5group, fname)
            obj.attributes = mapAttributes(h5group, fname);
        end
        
        function addDataLinks(obj, responseGroups)
            n = length(responseGroups);
            obj.dataLinks = containers.Map;
            
            for i = 1 : n
                h5Name = responseGroups(i).Name;
                delimInd = strfind(h5Name, '/');
                streamName = h5Name(delimInd(end)+1:end);
                streamLink = [h5Name, '/data'];
                obj.dataLinks(streamName) = streamLink;
            end
        end
        
        function plotData(obj, streamName, ax)
            
            if nargin < 3
                ax = gca;
            end
            
            if nargin < 2
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            
            [data, xvals, units] = obj.getData(streamName);
            
            if isempty(data)
                return
            end
            
            stimLen = obj.get(AnalysisConstant.STIM_TIME) * 1e-3; %seconds
            %TODO remove code duplication of plots in cell data and epoch data
            plot(ax, xvals, data);
            if ~isempty(stimLen)
                hold(ax, 'on');
                startLine = line('Xdata', [0 0],...
                    'Ydata', get(ax, 'ylim'), ...
                    'Color', 'k',...
                    'LineStyle', '--');
                endLine = line('Xdata', [stimLen stimLen],...
                    'Ydata', get(ax, 'ylim'), ...
                    'Color', 'k',...
                    'LineStyle', '--');
                set(startLine, 'Parent', ax);
                set(endLine, 'Parent', ax);
            end
            xlabel(ax, 'Time (s)');
            ylabel(ax, units);
            hold(ax, 'off');
        end
        
        function val = get(obj, paramName)
            val = nan;
            
            if obj.attributes.isKey(paramName)
                val = obj.attributes(paramName);
            end
        end
        
        function detectSpikes(obj, params, streamName)
    
            if nargin < 3
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            
            data = obj.getData(streamName);
            
            cellAttached = (strcmp(streamName, AnalysisConstant.AMP_CH_ONE) &&...
                strcmp(obj.get(AnalysisConstant.AMP_CH_ONE_MODE), AnalysisConstant.AMP_MODE_CELL_ATTACHED)) ...
                || (strcmp(streamName, AnalysisConstant.AMP_CH_TWO) &&...
                strcmp(obj.get(AnalysisConstant.AMP_CH_TWO_MODE), AnalysisConstant.AMP_MODE_CELL_ATTACHED));
            
            
            if ~ cellAttached
                return
            end
            
            if strcmp(params.spikeDetectorMode, AnalysisConstant.SPIKE_DETECTION_SIMPLE_THRESHOLD)
                data = data - mean(data);
                sp = getThresCross(data, params.spikeThreshold, sign(params.spikeThreshold));
            else
                sampleRate = obj.get(AnalysisConstant.SAMPLE_RATE);
                spikeResults = SpikeDetector_simple(data, 1./sampleRate, obj.spikeThreshold);
                sp = spikeResults.sp;
            end
            
            if strcmp(streamName, AnalysisConstant.AMP_CH_ONE)
                obj.attributes(AnalysisConstant.SPIKES_CH_ONE) = sp;
            else
                obj.attributes(AnalysisConstant.SPIKES_CH_TWO) = sp;
            end
        end
        
        function [spikeTimes, timeAxis] = getSpikes(obj, streamName)
            
            if nargin < 2
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            
            spikeTimes = nan;
            
            if strcmp(streamName, AnalysisConstant.AMP_CH_ONE)
                spikeTimes = obj.get(AnalysisConstant.SPIKES_CH_ONE);
            elseif strcmp(streamName, AnalysisConstant.AMP_CH_TWO)
                spikeTimes = obj.get(AnalysisConstant.SPIKES_CH_TWO);
            end
            
            sampleRate = obj.get(AnalysisConstant.SAMPLE_RATE);
            dataPoints = length(obj.getData(streamName));
            stimStart = obj.get(AnalysisConstant.STIM_TIME) * 1e-3; %s
            
            if isnan(stimStart)
                stimStart = 0;
            end
            timeAxis = (0 : 1/sampleRate : dataPoints/sampleRate) - stimStart;
        end
        
        function [data, xvals, units] = getData(obj, streamName)
            
            global RAW_DATA_FOLDER;
            
            if nargin < 2
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            data = [];
            xvals = [];
            units = '';
            
            if ~ obj.dataLinks.isKey(streamName)
                return
            end
            
            fname = fullfile(RAW_DATA_FOLDER, [obj.parentCell.savedFileName '.h5']);
            response = h5read(fname, obj.dataLinks(streamName));
            data = response.quantity;
            units = deblank(response.units(:,1)');
            sampleRate = obj.get(AnalysisConstant.SAMPLE_RATE);
            
            %temp hack
            preTime = obj.get(AnalysisConstant.PRE_TIME);
            if ischar(preTime)
                preTime = str2double(obj.get(AnalysisConstant.PRE_TIME));
            end
            obj.attributes(AnalysisConstant.PRE_TIME) = preTime;
            stimStart = preTime * 1e-3; %s
            
            if isnan(stimStart)
                stimStart = 0;
            end
            xvals = (1: length(data)) / sampleRate - stimStart;
            
        end
        
        function display(obj)
            displayAttributeMap(obj.attributes)
        end
        
    end
end