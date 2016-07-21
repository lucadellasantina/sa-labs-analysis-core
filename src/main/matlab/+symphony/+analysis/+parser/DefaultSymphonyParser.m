classdef DefaultSymphonyParser < symphony.analysis.parser.SymphonyParser
    
    properties
        cellData
    end
    
    methods
        
        function obj = parse(obj)
            import symphony.analysis.constants.*;
            import symphony.analysis.core.*;
            
            data = CellData();
            [~, data.savedFileName, ~] = fileparts(obj.fname);
            
            info = h5info(obj.fname);
            info = info.GroupHierarchy(1);
            
            data.attributes = obj.mapAttributes(info.Groups(1));
            n = length(info.Groups);
            
            EpochDataGroups = [];
            for i = 1 : n
                EpochDataGroups = [EpochDataGroups info.Groups(i).Groups(2).Groups]; %#ok
            end
            
            index = 1;
            epochTimes = [];
            for i = 1 : length(EpochDataGroups)
                
                if length(EpochDataGroups(i).Groups) >= 3 %Complete epoch
                    attributeMap = obj.mapAttributes(EpochDataGroups(i));
                    epochTimes(index) = attributeMap(AnalysisConstant.H5_EPOCH_START_TIME); %#ok
                    okEpochInd(index) = i; %#ok
                    index = index + 1;
                end
            end
            
            nEpochs = length(epochTimes);
            
            if nEpochs < 0
                return
            end
            
            [epochTimes_sorted, indices] = sort(epochTimes);
            epochTimes_sorted = epochTimes_sorted - epochTimes_sorted(1);
            epochTimes_sorted = double(epochTimes_sorted) / 1E7; % Ticks to second
            
            data.epochs = EpochData.empty(nEpochs, 0);
            for i = 1 : nEpochs
                
                groupInd = okEpochInd(indices(i));
                epoch = EpochData();
                epoch.attributes(AnalysisConstant.EPOCH_START_TIME) = epochTimes_sorted(i);
                epoch.attributes(AnalysisConstant.EPOCH_NUMBER) = i;
                epoch.parentCell = data;
                epoch.attributes = obj.mapAttributes(EpochDataGroups(groupInd).Groups(1));
                epoch.dataLinks = obj.addDataLinks(EpochDataGroups(groupInd).Groups(2).Groups);
                epoch.response = @(stream) h5read(obj.fname, epoch.dataLinks(stream));
                data.epochs(i) = epoch;
            end
            data.attributes(AnalysisConstant.TOTAL_EPOCHS) = nEpochs;
            obj.cellData = data;
        end
        
        function map = addDataLinks(~, responseGroups)
            n = length(responseGroups);
            map = containers.Map();
            
            for i = 1 : n
                h5Name = responseGroups(i).Name;
                delimInd = strfind(h5Name, '/');
                streamName = h5Name(delimInd(end) + 1 : end);
                streamLink = [h5Name, '/data'];
                map(streamName) = streamLink;
            end
        end
        
        function data = getResult(obj)
            data = obj.cellData;
        end
        
    end
    
end

