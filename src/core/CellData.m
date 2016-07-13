classdef CellData < handle
    
    properties
        attributes                          % Map for attributes from data file (h5group root attributes + Nepochs)
        epochs                              % Array of EpochData
        epochGroups                         % TODO
        savedDataSets = containers.Map()    % DataSets saved from cell data curator
        savedFileName = ''                  % Current H5 file name without extension
        savedFilters = containers.Map()     % TODO
        tags = containers.Map()             % TODO
        cellType = ''                       % CellType will be assignment from LabDataGUI
        prefsMapName = ''                   % TODO
        somaSize = []                       % TODO
        imageFile = ''                      % Cell image
        notes = ''                          % Unstructured text field for adding notes
        location = []                       % [X, Y, whichEye] (X,Y in microns; whichEye is -1 for left eye and +1 for right eye)
    end
    
    methods
        
        function obj = CellData(fname)
            % CellData - creates celldata class object from raw data file
            %   (1) If nargin < 1 then util/recordings/symphony2Mapper is responsible for
            %       constructing cell data object
            %   (2) Otherwise it constructs array of epochData with
            %       protocol parameter as attributes & data links for
            %       amplifier streams
            
            if nargin < 1
                return
            end
            
            [~, obj.savedFileName, ~] = fileparts(fname);
            info = hdf5info(fname,'ReadAttributes',false);
            info = info.GroupHierarchy(1);
            
            obj.attributes = mapAttributes(info.Groups(1), fname);
            n = length(info.Groups);
            
            EpochDataGroups = [];
            for i = 1 : n
                EpochDataGroups = [EpochDataGroups info.Groups(i).Groups(2).Groups]; %#ok
            end
            
            index = 1;
            epochTimes = [];
            for i = 1 : length(EpochDataGroups)
                
                if length(EpochDataGroups(i).Groups) >= 3 %Complete epoch
                    attributeMap = mapAttributes(EpochDataGroups(i), fname);
                    epochTimes(index) = attributeMap(AnalysisConstant.H5_EPOCH_START_TIME); %#ok
                    okEpochInd(index) = i; %#ok
                    index = index + 1;
                end
            end
            
            nEpochs = length(epochTimes);
            if nEpochs < 0
                return;
            end
            
            [epochTimes_sorted, indices] = sort(epochTimes);
            epochTimes_sorted = epochTimes_sorted - epochTimes_sorted(1);
            epochTimes_sorted = double(epochTimes_sorted) / 1E7; % Ticks to second
            
            obj.epochs = EpochData.empty(nEpochs, 0);
            for i = 1 : nEpochs
                
                groupInd = okEpochInd(indices(i));
                curEpoch = EpochData();
                curEpoch.attributes(AnalysisConstant.EPOCH_START_TIME) = epochTimes_sorted(i);
                curEpoch.attributes(AnalysisConstant.EPOCH_NUMBER) = i;
                curEpoch.parentCell = obj;
                curEpoch.loadParams(EpochDataGroups(groupInd).Groups(1), fname);
                curEpoch.addDataLinks(EpochDataGroups(groupInd).Groups(2).Groups);
                obj.epochs(i) = curEpoch;
            end
            obj.attributes(AnalysisConstant.TOTAL_EPOCHS) = nEpochs;
        end
        
        function vals = getEpochVals(obj, paramName, indices)
            % getEpochVals - returns list (or) matrices of parameter values
            % for the given param name and for the given indices.
            
            if nargin < 3
                indices = 1 : obj.get(AnalysisConstant.TOTAL_EPOCHS);
            end
            n = length(indices);
            
            if isempty(n)
                vals = [];
                return;
            end
            
            vals = cell(1,n);
            numbers = true;
            
            for i = 1 : n
                value = NaN;
                v = obj.epochs(indices(i)).get(paramName);
                
                if ~ isempty(v) && ~ strcmp(v, '<null>') % Temp hack: null string?
                    value = v;
                end
                
                if ~ isnumeric(value)
                    numbers = false;
                else
                    value = double(value);
                end
                vals{i} = value;
            end
            
            if numbers
                vals = cell2mat(vals);
            end
        end
        
        function allKeys = getEpochKeysetUnion(obj, indices)
            
            if nargin < 2
                indices = 1 : obj.get(AnalysisConstant.TOTAL_EPOCHS);
            end
            allKeys = [];
            n = length(indices);
            
            if isempty(n)
                return
            end
            
            keySet = [];
            % poor implementation for finding unique elements
            for i = 1 : n
                keySet = [keySet obj.epochs(indices(i)).attributes.keys];
            end
            
            allKeys = unique(keySet);
        end
        
        function [params, vals] = getNonMatchingParamVals(obj, epochInd, excluded)
            
            if nargin < 3
                excluded = '';
            end
            
            excluded = {excluded, AnalysisConstant.NUMBER_OF_AVERAGES,...
                AnalysisConstant.EPOCH_START_TIME, AnalysisConstant.EPOCH_NUMBER,...
                AnalysisConstant.EPOCH_IDENTIFIER };
            
            allKeys = obj.getEpochKeysetUnion(epochInd);
            n = length(allKeys);
            params = {};
            vals = {};
            index = 1;
            
            for i = 1 : n
                key = allKeys{i};
                if ~ strcmp(key, excluded)
                    values = getEpochVals(obj, key, epochInd);
                    values = values(~ isnan_cell(values));
                    
                    if iscell(values)
                        for j = 1 : length(values)
                            if isnumeric(values{j})
                                values{j} = num2str(values{j});
                            end
                        end
                    end
                    uniqueVals = unique(values);
                    
                    if length(uniqueVals) > 1
                        params{index} = allKeys{i};
                        vals{index} = uniqueVals;
                        index = index + 1;
                    end
                end
            end
        end
        
        function [dataMean, xvals, dataStd, units] = getMeanData(obj, epochInd, streamName)
            
            if nargin < 3
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            n = length(epochInd);
            
            dataPoints = length(obj.epochs(epochInd(1)).getData(streamName));
            data = zeros(n, dataPoints);
            
            for i = 1 : n
                [curData, curXvals, curUnits] = obj.epochs(epochInd(i)).getData(streamName);
                if i == 1
                    xvals = curXvals;
                    units = curUnits;
                end
                data(i,:) = curData;
            end
            dataMean = mean(data,1);
            dataStd = std(data,1);
        end
        
        function [spCount, xvals] = getPSTH(obj, epochInd, binWidth, streamName)
            
            if nargin < 4
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            
            if nargin < 3 || isempty(binWidth)
                binWidth = 10; % ms
            end
            
            sampleEpoch = obj.epochs(epochInd(1));
            dataPoints = length(sampleEpoch.getData(streamName));
            sampleRate = sampleEpoch.get(AnalysisConstant.SAMPLE_RATE);
            samplesPerMS = round(sampleRate/1E3);
            samplesPerBin = round(binWidth * samplesPerMS);
            bins = 0 : samplesPerBin : dataPoints;
            
            %compute PSTH
            allSpikes = [];
            for i= 1 : length(epochInd);
                allSpikes = [allSpikes, obj.epochs(epochInd(i)).getSpikes(streamName)]; %#ok
            end
            
            spCount = histc(allSpikes, bins);
            if isempty(spCount)
                spCount = zeros(1, length(bins));
            end
            
            stimStart = sampleEpoch.get('preTime') * 1e-3; %s
            if isnan(stimStart)
                stimStart = 0;
            end
            xvals = bins/sampleRate - stimStart;
            %convert to Hz
            spCount = spCount / n / (binWidth*1E-3);
        end
        
        function detectSpikes(obj, mode, threshold, epochInd, interactive, streamName)
            
            if nargin < 6
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            
            if nargin < 5
                interactive = true;
            end
            
            if nargin < 4
                epochInd = 1 : obj.get(AnalysisConstant.TOTAL_EPOCHS);
            end
            
            if nargin < 3
                threshold = 15;
            end
            
            if nargin < 2
                mode = AnalysisConstant.SPIKE_DETECTION_STD_DEV;
            end
            
            n = length(epochInd);
            params.spikeDetectorMode = mode;
            params.spikeThreshold = threshold;
            
            if interactive
                SpikeDetectorGUI(obj, epochInd, params, streamName);
            else
                for i = 1 : n
                    obj.epochs(epochInd(i)).detectSpikes(params, streamName);
                end
            end
            
        end
        
        function dataSet = filterEpochs(obj, queryString, subSet)
            
            if nargin < 3
                subSet = 1 : obj.get(AnalysisConstant.TOTAL_EPOCHS);
            end
            
            n = length(subSet);
            dataSet = [];
            
            if strcmp(queryString, '?') || isempty(queryString)
                dataSet = 1 : n;
                return
            end
            
            for i = 1 : n
                M = obj.epochs(subSet(i)); %variable name of map in query string is M
                if eval(queryString)
                    dataSet = [dataSet subSet(i)];
                end
            end
        end
        
        function val = filterCell(obj, queryString)
            % returns true or false for this cell
            
            if strcmp(queryString, '?') || isempty(queryString)
                val = true;
                return
            end
            
            M = obj; %variable name of map in query string is M
            val = eval(queryString);
        end
        
        function val = get(obj, paramName)
            % get - Checks attributes and tags
            
            if ~ obj.attributes.isKey(paramName) && ~ obj.tags.isKey(paramName)
                val = nan;
            elseif obj.tags.isKey(paramName) %tags take precedence over attributes
                val = obj.tags(paramName);
            else
                val = obj.attributes(paramName);
            end
        end
        
        function plotMeanData(obj, epochInd, subtractBaseline, lowPass, streamName)
            
            if nargin < 5
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            
            if nargin < 4
                lowPass = [];
                subtractBaseline = true;
            end
            
            [dataMean, xvals, dataStd, units] = obj.getMeanData(epochInd, streamName); %#ok Could use dataStd to plot with error lines
            
            if isempty(dataMean)
                return
            end
            
            ax = gca;
            sampleEpoch = obj.epochs(epochInd(1));
            sampleRate = sampleEpoch.get(AnalysisConstant.SAMPLE_RATE);
            stimLen = sampleEpoch.get(AnalysisConstant.STIM_TIME) * 1e-3;
            
            if ~ isempty(lowPass)
                dataMean = LowPassFilter(dataMean, lowPass, 1/sampleRate);
            end
            
            if subtractBaseline
                baseline = mean(dataMean(xvals < 0));
                if isnan(baseline) % Hack for missing baseline time
                    baseline = mean(dataMean(xvals < 0.25)); %use 250 ms
                end
                dataMean = dataMean - baseline;
            end
            
            plot(ax, xvals, dataMean);
            if ~ isempty(stimLen)
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
        
        function plotSpikeRaster(obj, epochInd, streamName)
            if nargin < 3
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            
            % Get spikes
            n = length(epochInd);
            spikeTimes = cell(n, 1);
            for i = 1 : n
                [spikeTimes{i}, timeAxis_spikes] = obj.epochs(epochInd(i)).getSpikes(streamName);
            end
            ax = gca;
            hold(ax, 'on');
            
            % Line display
            for i=1:n
                spikes = timeAxis_spikes(spikeTimes{i});
                for st_i = 1 : length(spikes)
                    x = spikes(st_i);
                    line([x, x], [i-0.4, i+0.4]);
                end
            end
            
            set(ax, 'Ytick', 1:1:n);
            set(ax, 'Xlim', [timeAxis_spikes(1), timeAxis_spikes(end)]);
            set(ax, 'Ylim', [0, n+1]);
            
            sampleEpoch = obj.epochs(epochInd(1));
            stimLen = sampleEpoch.get(AnalysisConstant.STIM_TIME) * 1e-3; %s
            
            if ~ isempty(stimLen)
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
            ylabel(ax, 'Trials');
        end
        
        function plotPSTH(obj, epochInd, binWidth, streamName)
            if nargin < 4
                streamName = AnalysisConstant.AMP_CH_ONE;
            end
            if nargin < 3
                binWidth = 10;
            end
            
            ax = gca;
            sampleEpoch = obj.epochs(epochInd(1));
            stimLen = sampleEpoch.get(AnalysisConstant.STIM_TIME) * 1e-3; %s
            [spCount, xvals] = obj.getPSTH(epochInd, binWidth, streamName);
            
            plot(ax, xvals, spCount);
            if ~ isempty(stimLen)
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
            ylabel(ax, 'Spike rate (Hz)');
            %hold(ax, 'off');
        end
        
        function display(obj)
            displayAttributeMap(obj.attributes);
        end
        
    end
    
end