classdef CellData < handle & matlab.mixin.CustomDisplay
    
    properties
        attributes                          % Map for attributes from data file (h5group root attributes + Nepochs)
        epochs                              % Array of EpochData
        epochGroups                         % TODO
        savedDataSets                       % DataSets saved from cell data curator
        savedFileName = ''                  % Current H5 file name without extension
        savedFilters                        % TODO
        tags                                % TODO
        cellType = ''                       % CellType will be assignment from LabDataGUI
        prefsMapName = ''                   % TODO
        somaSize = []                       % TODO
        imageFile = ''                      % Cell image
        notes = ''                          % Unstructured text field for adding notes
        location = []                       % [X, Y, whichEye] (X,Y in microns; whichEye is -1 for left eye and +1 for right eye)
    end
    
    methods
        
        function obj = CellData()
            obj.attributes = containers.Map();
            obj.savedDataSets = containers.Map();
            obj.savedFilters = containers.Map();
            obj.tags = containers.Map();
        end
        
        function [values, parameterDescription] = getEpochValues(obj, parameter, epochIndices)
            
            % getEpochValues - By deafult returns attribute values of epochs
            % for given attribute and epochIndices .
            %
            % If the parameter is a function handle, it applies the function
            % to given epoch and returns its value
            %
            % Parameter - epoch attributes or function handle
            % epochIndices - list of epoch indices to be lookedup
            %
            % Usage -
            %      obj.getEpochValues('r_star', [1:100])
            %      obj.getEpochValues(@(epoch) calculateRstar(epoch), [1:100])
            
            fun = @(epoch) epoch.get(parameter);
            parameterDescription = parameter;
            
            if isa(parameter, 'function_handle')
                fun = parameter;
                parameterDescription = func2str(fun);
            end
            n = length(epochIndices);
            values = cell(1,n);
            
            for i = 1 : n
                value = fun(obj.epochs(epochIndices(i)));
                values{i} = value;
            end
            if sum(cellfun(@isnumeric, values)) == n
                values = cell2mat(values);
            end
        end
        
        function keys = getEpochKeysetUnion(obj, epochIndices)
            
            % getEpochKeysetUnion - returns unqiue attributes from epoch
            % array
            
            n = length(epochIndices);
            keySet = [];
            
            for i = 1 : n
                keySet = [keySet obj.epochs(epochIndices(i)).attributes.keys]; %#ok
            end
            keys = unique(keySet);
        end
        
        function [params, vals] = getNonMatchingParamValues(obj, epochInd, excluded)
            
            % getNonMatchingParamValues - returns unqiue attributes & values
            % apart from excluded attributes
            
            keys = setdiff(obj.getEpochKeysetUnion(epochInd), excluded);
            map = containers.Map();
            
            for i = 1 : length(keys)
                values = obj.getEpochValues(keys{i}, epochInd);
                map(key) =  unique(values);
            end
            params = map.keys;
            vals = map.values;
        end
        
        function val = get(obj, paramName)
            
            % get - Returns value for given parameter name
            % Tags take precedence over attributes
            
            val = Nan;
            if obj.tags.isKey(paramName)
                val = obj.tags(paramName);
            end
            
            if obj.attributes.isKey(paramName)
                val = obj.attributes(paramName);
            end
        end
        
        function dataSet = filterEpochs(obj, queryString, subSet)
            
            n = length(subSet);
            dataSet = [];
            
            if strcmp(queryString, '?') || isempty(queryString)
                dataSet = 1 : n;
                return
            end
            
            fun = str2func(queryString);
            for i = 1 : n
                d = obj.epochs(subSet(i)); % variable name of map in query string is M
                if fun(d)
                    dataSet = [dataSet subSet(i)]; %#ok
                end
            end
        end
        
        function tf = filterCell(obj, queryString)
            % returns true or false for this cell
            
            if strcmp(queryString, '?') || isempty(queryString)
                tf = true;
                return
            end
            fun = str2func(queryString);
            tf = fun(obj);
        end
        
    end
    
    methods(Access = protected)
        
        function header = getHeader(obj)
            type = obj.cellType;
            if isempty(type)
                type = 'unassigned';
            end
            header = ['Displaying information about ' type ' cell type '];
        end
        
        function groups = getPropertyGroups(obj)
            attrKeys = obj.attributes.keys;
            dataSetKeys = obj.savedDataSets.keys;
            groups = matlab.mixin.util.PropertyGroup.empty(0, 2);
            
            display = struct();
            for i = 1 : numel(attrKeys)
                display.(attrKeys{i}) = obj.attributes(attrKeys{i});
            end
            groups(1) = display;
            groups(2) = dataSetKeys;
        end
    end
    
end