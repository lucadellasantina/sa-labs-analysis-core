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
        
        function values = getEpochValues(obj, parameter, indices)
            fun = @(epoch) epoch.get(parameter);
            
            if isa(parameter, 'function_handle')
                fun = parameter;
            end
            n = length(indices);            
            values = cell(1,n);
            
            for i = 1 : n
                value = fun(obj.epochs(indices(i)));
                values{i} = value;
            end
            if sum(cellfun(@isnumeric, values)) == n
                values = cell2mat(values);
            end
        end
        
        function ds = createNewDataSet(dataSet, values, uniqueValue)
            ds = [];
            %TODO 
        end
        
        function keys = getEpochKeysetUnion(obj, indices)
            n = length(indices);
            keySet = [];
            
            for i = 1 : n
                keySet = [keySet obj.epochs(indices(i)).attributes.keys]; %#ok
            end
            keys = unique(keySet);
        end
        
        function [params, vals] = getNonMatchingParamVals(obj, epochInd, excluded)
            
            keys = setdiff(obj.getEpochKeysetUnion(epochInd), excluded);
            map = containers.Map();
            
            for i = 1 : length(keys)
                values = obj.getEpochVals(keys{i}, epochInd);
                map(key) =  unique(values);
            end
            params = map.keys;
            vals = map.values;
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
        
        function tf = filterCell(obj, queryString)
            % returns true or false for this cell
            
            if strcmp(queryString, '?') || isempty(queryString)
                tf = true;
                return
            end
            
            M = obj; %variable name of map in query string is M
            tf = eval(queryString);
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
        
    end
    
end