function cell = symphony2Mapper(fname)
   
    cell = CellData();
    cell.attributes = containers.Map();
    
    info = h5info(fname);
    epochGroups = arrayfun(@(g) g.Groups(1), info.Groups(1).Groups(2));
    epochs = getEpochsData(fname, epochGroups, cell);

    cell.epochs = epochs;
    cell.attributes('Nepochs') = numel(epochs);

end

function epochsData = getEpochsData(fname, epochGroups, obj)

    parameters = epochGroups.Groups(1).Groups(1).Groups(2);
    parameterMap = containers.Map();

    for i = 1: numel(parameters.Attributes)
        parameterMap(parameters.Attributes(i).Name) = parameters.Attributes(i).Value;
    end

    epochs = epochGroups.Groups(1).Groups(1).Groups(1);
    epochsTime = arrayfun(@(epoch) h5readatt(fname, epoch.Name, 'startTimeDotNetDateTimeOffsetTicks'), epochs.Groups);

    [time, indices] = sort(epochsTime);
    sortedEpochTime = double(time - time(1)).* 1e-7;

    epochsData = EpochData.empty(numel(epochs.Groups), 0);

    for i = 1: numel(epochs.Groups)

        attributesMap = parameterMap;
        attributesMap('epochNum') = i;
        attributesMap('epochStartTime') = sortedEpochTime(i);

        groupIndex = indices(i);
        epochParameters = epochs.Groups(groupIndex).Groups(2).Attributes;

        for j = 1: numel(epochParameters)
            attributesMap(epochParameters(j).Name) = epochParameters(j).Value;
        end

        dataLinksMap = containers.Map();
        responses = epochs.Groups(groupIndex).Groups(3).Groups;

        for k = 1 : numel(responses)
            responseName = responses(k).Name;

            delimeter = strfind(responseName, '/');
            deviceId = responseName(delimeter(end) + 1 : end);
            delimeter = strfind(deviceId, '-');
            name = deviceId(1: delimeter(1));

            dataLinksMap(name) =  [responseName '/data'];
        end

        e = EpochData();
        e.attributes = attributesMap;
        e.dataLinks = dataLinksMap;
        e.parentCell = obj;
        epochsData(i) = e;
    end
end
