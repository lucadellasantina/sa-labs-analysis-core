classdef Symphony2Parser < sa_labs.analysis.parser.SymphonyParser
    
    % experiement (1)
    %   |__devices (1)
    %   |__epochGroups (2)
    %       |_epochGroup-uuid
    %           |_epochBlocks (1)
    %               |_<protocol_class>-uuid (1) #protocols
    %                   |_epochs (1)
    %                   |   |_epoch-uuid (1)    #h5EpochLinks
    %                   |      |_background (1)
    %                   |      |_protocolParameters (2)
    %                   |      |_responses (3)
    %                   |        |_<device>-uuid (1)
    %                   |            |_data (1)
    %                   |_protocolParameters(2)
    
    properties
        cellDataArray
    end
    
    methods
        
        function obj = parse(obj)
            import sa_labs.analysis.*;
            
            info = h5info(obj.fname);
            epochsByCellMap = obj.getEpochsByCellLabel(info.Groups(1).Groups(2).Groups);
            sourceTree = obj.buildSourceTree(info.Groups(1).Groups(5).Links.Value{:});
            
            numberOfCells = numel(epochsByCellMap.keys);
            cells = entity.CellData.empty(numberOfCells, 0);
            labels = epochsByCellMap.keys;
            
            for i = 1 : numberOfCells
                h5epochs =  epochsByCellMap(labels{i});
                cells(i) = obj.buildCellData(labels{i}, h5epochs);
                cells(i).attributes = obj.getSourceAttributes(sourceTree, labels{i}, cells(i).attributes);

                if isKey(cells(i).attributes, 'eye')
                    cells(i).location = [cells(i).attributes('location'), obj.getEyeIndex(cells(i).attributes('eye'))];
                end
                
            end
            obj.cellDataArray = cells;
        end
        
        function d = getResult(obj)
            d = obj.cellDataArray;
        end
        
        function eyeIndex = getEyeIndex(~, location)
            if strcmpi(location, 'left')
                eyeIndex = -1;
            elseif strcmpi(location, 'right')
                eyeIndex = 1;
            end
        end
        
        function cell = buildCellData(obj, label, h5Epochs)
            import sa_labs.analysis.constants.*;
            import sa_labs.analysis.*;
            
            cell = entity.CellData();
            
            epochsTime = arrayfun(@(epoch) h5readatt(obj.fname, epoch.Name, 'startTimeDotNetDateTimeOffsetTicks'), h5Epochs);
            [time, indices] = sort(epochsTime);
            sortedEpochTime = double(time - time(1)).* 1e-7;
            
            lastProtocolId = [];
            epochData = entity.EpochData.empty(numel(h5Epochs), 0);
            
            for i = 1 : numel(h5Epochs)
                
                index = indices(i);
                epochPath = h5Epochs(index).Name;
                [protocolId, name, protocolPath] = obj.getProtocolId(epochPath);
                
                if ~ strcmp(protocolId, lastProtocolId)
                    % start of new protocol
                    parameterMap = obj.buildAttributes(protocolPath);
                    name = strsplit(name, '.');
                    name = obj.convertDisplayName(name{end});
                    parameterMap('displayName') = name;
                end
                lastProtocolId = protocolId;
                
                parameterMap = obj.buildAttributes(h5Epochs(index).Groups(2), parameterMap);
                parameterMap('epochNum') = i;
                parameterMap('epochStartTime') = sortedEpochTime(i);
                
                e = entity.EpochData();
                e.parentCell = cell;
                e.attributes = containers.Map(parameterMap.keys, parameterMap.values);
                e.dataLinks = obj.getResponses(h5Epochs(index).Groups(3).Groups);
                e.responseHandle = @(path) h5read(obj.fname, path);
                epochData(i) = e;
            end
            
            cell.attributes = containers.Map();
            cell.epochs = epochData;
            cell.attributes('Nepochs') = numel(h5Epochs);
            cell.attributes('symphonyVersion') = 2.0;
            cell.attributes('fname') = obj.getFileName(label);
        end
        
        function epochGroupMap = getEpochsByCellLabel(obj, epochGroups)
            epochGroupMap = containers.Map();
            import sa_labs.analysis.util.collections.*;
            
            for i = 1 : numel(epochGroups)
                h5Epochs = flattenByProtocol(epochGroups(i).Groups(1).Groups);
                label = obj.getSourceLabel(epochGroups(i));
                epochGroupMap = addToMap(epochGroupMap, label, h5Epochs);
            end
            
            function epochs = flattenByProtocol(protocols)
                epochs = arrayfun(@(p) p.Groups(1).Groups, protocols, 'UniformOutput', false);
                idx = find(~ cellfun(@isempty, epochs));
                epochs = cell2mat(epochs(idx));
            end
        end
        
        function label = getSourceLabel(obj, epochGroup)
            % check if it is h5 Groups
            % if not present it should be in links
            
            if numel(epochGroup.Groups) >= 4
                source = epochGroup.Groups(end).Name;
            else
                source = epochGroup.Links(2).Value{:};
            end
            label = h5readatt(obj.fname, source, 'label');
        end
        
        function fname = getFileName(obj, label)
            [~, file, ~] = fileparts(obj.fname);
            index = regexp(label, '[0-9]+');
            
            if index == 1
                fname = [file 'c' label];
            elseif index == 2
                fname = [file 'c' label(2:end)];
            elseif index == 3
                fname = [file 'c' label(3:end)];
            else
                fname = file;
            end
        end
        
        function attributeMap = buildAttributes(obj, h5group, map)
            if nargin < 3
                map = containers.Map();
            end
            
            map = obj.mapAttributes(h5group, map);
            attrs = cellfun(@(key) obj.getMappedAttribute(key), map.keys, 'UniformOutput', false);
            attributeMap = containers.Map(attrs, map.values);
        end
        
        function sourceTree = buildSourceTree(obj, sourceLink, sourceTree, level)
            
            if nargin < 3
                sourceTree = tree();
                level = 0;
            end
            sourceGroup = h5info(obj.fname, sourceLink);
            
            label = h5readatt(obj.fname, sourceGroup.Name, 'label');
            map = containers.Map();
            map('label') = label;
            
            sourceProperties = [sourceGroup.Name '/properties'];
            map = obj.mapAttributes(sourceProperties, map);
            
            sourceTree = sourceTree.addnode(level, map);
            level = level + 1;
            childSource = h5info(obj.fname, [sourceGroup.Name '/sources']);
            
            for i = 1 : numel(childSource.Groups)
                sourceTree = obj.buildSourceTree(childSource.Groups(i).Name, sourceTree, level);
            end
        end
        
        function [id, name, path] = getProtocolId(~, epochPath)
            
            indices = strfind(epochPath, '/');
            id = epochPath(indices(end-2) + 1 : indices(end-1) - 1);
            path = [epochPath(1 : indices(end-1) - 1) '/protocolParameters'] ;
            nameArray = strsplit(id, '-');
            name = nameArray{1};
        end
        
        function map = getResponses(~, responseGroups)
            map = containers.Map();
            
            for i = 1 : numel(responseGroups)
                devicePath = responseGroups(i).Name;
                indices = strfind(devicePath, '/');
                id = devicePath(indices(end) + 1 : end);
                deviceArray = strsplit(id, '-');
                
                name = deviceArray{1};
                path = [devicePath, '/data'];
                map(name) = path;
            end
        end
        
        function map = getSourceAttributes(~, sourceTree, label, map)
            import sa_labs.analysis.util.collections.*;
            id = find(sourceTree.treefun(@(node) strcmp(node('label'), label)));
            
            while id > 0
                currentMap = sourceTree.get(id);
                keys = currentMap.keys;
                for i = 1 : numel(keys)
                    k = keys{i};
                    map = addToMap(map, k, currentMap(k));
                end
                id = sourceTree.getparent(id);
            end
        end
        
        function mappedAttr = getMappedAttribute(~, name)
            switch name
                case 'chan1Mode'
                    mappedAttr = 'ampMode';
                case 'chan2Mode'
                    mappedAttr = 'amp2Mode';
                case 'chan1Hold'
                    mappedAttr = 'ampHoldSignal';
                case 'chan2Hold'
                    mappedAttr = 'amp2HoldSignal';
                otherwise
                    mappedAttr = name;
            end
        end
    end
    
end

