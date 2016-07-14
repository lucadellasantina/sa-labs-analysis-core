classdef LightStepAnalysis < AnalysisTree
    
    properties
        StartTime = 0
        EndTime = 0
    end
    
    methods
        
        function obj = LightStepAnalysis(cellData, dataSetName, params)
            
            if nargin < 3
                params.deviceName = AnalysisConstant.AMP_CH_ONE;
            end
            
            if strcmp(params.deviceName, AnalysisConstant.AMP_CH_ONE)
                params.ampModeParam =  AnalysisConstant.AMP_CH_ONE_MODE;
            else
                params.ampModeParam = AnalysisConstant.AMP_CH_TWO_MODE;
            end
            
            name = [cellData.savedFileName ': ' dataSetName ' : ' class(obj)];
            protocolAttributes = {'RstarIntensity', params.ampModeParam, 'amplifierMode'};
            dataSet = cellData.savedDataSets(dataSetName);
            
            obj = obj.setName(name);
            obj = obj.copyAnalysisParams(params);
            obj = obj.copyParamsFromSampleEpoch(cellData, dataSet, protocolAttributes);
            obj = obj.buildCellTree(1, cellData, dataSet, {'RstarMean'});
        end
        
        function obj = doAnalysis(obj, cellData)
            
            rootData = obj.get(1);
            leafIDs = obj.findleaves();
            
            for i = 1 : length(leafIDs) %for each leaf node
                node = obj.get(leafIDs(i));
                
                if strcmp(rootData.(rootData.ampModeParam), 'Cell attached')
                    outputStruct = getEpochResponses_CA(cellData, node.epochID, ...
                        'DeviceName', rootData.deviceName,'StartTime', obj.StartTime, 'EndTime', obj.EndTime);
                elseif strcmp(rootData.amplifierMode, 'IClamp')
                    %spike data?
                    spCount = cellData.getPSTH(node.epochID, [], rootData.deviceName);
                    if sum(spCount) > 0 %has spikes
                        outputStruct = getEpochResponses_CA(cellData, node.epochID, ...
                        'DeviceName', rootData.deviceName,'StartTime', obj.StartTime, 'EndTime', obj.EndTime);
                    else
                        outputStruct = getEpochResponses_WC(cellData, node.epochID, ...
                        'DeviceName', rootData.deviceName,'StartTime', obj.StartTime, 'EndTime', obj.EndTime);
                    end                                        
                else %whole cell, Vclamp
                    outputStruct = getEpochResponses_WC(cellData, node.epochID, ...
                        'DeviceName', rootData.deviceName,'StartTime', obj.StartTime, 'EndTime', obj.EndTime);
                end
                outputStruct = getEpochResponseStats(outputStruct);
                node = mergeIntoNode(node, outputStruct);
                obj = obj.set(leafIDs(i), node);
            end
            
        end
        
    end
    
    methods(Static)
  
        function plotMeanTrace(node, cellData)
            rootData = node.get(1);
            epochInd = node.get(2).epochID;
            if strcmp(rootData.(rootData.ampModeParam), 'Cell attached')
                cellData.plotPSTH(epochInd, 10, rootData.deviceName);
                %                 hold on
                %                 firingStart = node.get(2).meanONlatency;
                %                 firingEnd = firingStart + node.get(2).meanONenhancedDuration;
                %                 plot([firingStart firingEnd], [0 0]);
                %                 hold off
            else
                cellData.plotMeanData(epochInd, true, [], rootData.deviceName);
            end
            %title(['ON latency: ',num2str(node.get(2).meanONlatency),' ste: ',num2str(node.get(2).steONlatency)]);
        end
        
        function plotEpochData(node, cellData, device, epochIndex)
            nodeData = node.get(1);
            cellData.epochs(nodeData.epochID(epochIndex)).plotData(device);
            title(['Epoch # ' num2str(nodeData.epochID(epochIndex)) ': ' num2str(epochIndex) ' of ' num2str(length(nodeData.epochID))]);
            if strcmp(device, 'Amplifier_Ch1')
                spikesField = 'spikes_ch1';
            else
                spikesField = 'spikes_ch2';
            end
            spikeTimes = cellData.epochs(nodeData.epochID(epochIndex)).get(spikesField);
            if ~isnan(spikeTimes)
                [data, xvals] = cellData.epochs(nodeData.epochID(epochIndex)).getData(device);
                hold('on');
                plot(xvals(spikeTimes), data(spikeTimes), 'rx');
                hold('off');
            end
            
            ONendTime = cellData.epochs(nodeData.epochID(epochIndex)).get('stimTime')*1E-3; %s
            ONstartTime = 0;
            if isfield(nodeData, 'ONSETlatency')
                %draw lines here
                hold on
                firingStart = node.get(1).ONSETlatency.value(epochIndex)+ONstartTime;
                firingEnd = firingStart + node.get(1).ONSETrespDuration.value(epochIndex);
                burstBound = firingStart + node.get(1).ONSETburstDuration.value(epochIndex);
                upperLim = max(data)+50;
                lowerLim = min(data)-50;
                plot([firingStart firingStart], [upperLim lowerLim], 'LineStyle','--','Color',[1 0 0]);
                plot([firingEnd firingEnd], [upperLim lowerLim], 'LineStyle','--','Color',[1 0 0]);
                plot([burstBound burstBound], [upperLim lowerLim], 'LineStyle','--');
                hold off
            end;
            if isfield(nodeData, 'OFFSETlatency')
                %draw lines here
                hold on
                firingStart = node.get(1).OFFSETlatency.value(epochIndex)+ONendTime;
                firingEnd = firingStart + node.get(1).OFFSETrespDuration.value(epochIndex);
                burstBound = firingStart + node.get(1).OFFSETburstDuration.value(epochIndex);
                upperLim = max(data)+50;
                lowerLim = min(data)-50;
                plot([firingStart firingStart], [upperLim lowerLim], 'LineStyle','--','Color',[1 0 0]);
                plot([firingEnd firingEnd], [upperLim lowerLim], 'LineStyle','--','Color',[1 0 0]);
                plot([burstBound burstBound], [upperLim lowerLim], 'LineStyle','--');
                hold off
            end
            
        end
        
        
    end
end