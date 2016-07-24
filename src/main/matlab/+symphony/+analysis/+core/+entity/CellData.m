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
            
            if nargin < 3
                epochIndices = 1 : numel(obj.epochs);
            end
            
            functionHandle = @(epoch) epoch.get(parameter);
            parameterDescription = parameter;
            
            if isa(parameter, 'function_handle')
                functionHandle = parameter;
                parameterDescription = func2str(functionHandle);
            end
            n = length(epochIndices);
            values = cell(1,n);
            
            for i = 1 : n
                value = functionHandle(obj.epochs(epochIndices(i)));
                values{i} = value;
            end
            if sum(cellfun(@isnumeric, values)) == n
                values = cell2mat(values);
            end
        end
        
        function [map, parameterDescription] = getEpochValuesMap(obj, parameter, epochIndices)
            
            % getEpochValuesMap - By deafult returns attribute values as key
            % and matching epochs indices as values
            %
            % @ see also getEpochValues
            %
            % If the parameter is a function handle, it applies the function
            % to given epoch and returns its attribute values and epochs
            % indices
            %
            % Parameter - epoch attributes or function handle
            % epochIndices - list of epoch indices to be lookedup
            %
            % Usage -
            %      obj.getEpochValuesMap('r_star', [1:100])
            %      obj.getEpochValuesMap(@(epoch) calculateRstar(epoch), [1:100])
            
            if nargin < 3
                epochIndices = 1 : numel(obj.epochs);
            end
            
            functionHandle = @(epoch) epoch.get(parameter);
            parameterDescription = parameter;
            
            if isa(parameter, 'function_handle')
                functionHandle = parameter;
                parameterDescription = func2str(functionHandle);
            end
            n = length(epochIndices);
            map = containers.Map();
            
            for i = 1 : n
                epochIndex = epochIndices(i);
                epoch = obj.epochs(epochIndex);
                value = functionHandle(epoch);
                map = symphony.analysis.util.collections.addToMap(map, num2str(value), epochIndex);
            end
            
            keys = map.keys;
            if isempty([keys{:}])
                map = [];
            end
        end
        
        function keySet = getEpochKeysetUnion(obj, epochIndices)
            
            % getEpochKeysetUnion - returns unqiue attributes from epoch
            % array
            
            if nargin < 2
                epochIndices = 1 : numel(obj.epochs);
            end
            
            n = length(epochIndices);
            keySet = [];
            
            for i = 1 : n
                epoch = obj.epochs(epochIndices(i));
                keySet = epoch.unionAttributeKeys(keySet);
            end
        end
        
        function [params, vals] = getNonMatchingParamValues(obj, excluded, epochIndices)
            
            % getNonMatchingParamValues - returns unqiue attributes & values
            % apart from excluded attributes
            
            keys = setdiff(obj.getEpochKeysetUnion(epochIndices), excluded);
            map = containers.Map();
            
            for i = 1 : length(keys)
                values = obj.getEpochValues(keys{i}, epochIndices);
                map(key) =  unique(values);
            end
            params = map.keys;
            vals = map.values;
        end
        
        function val = get(obj, paramName)
            
            % get - Returns value for given parameter name
            % Tags take precedence over attributes
            
            val = [];
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
            
            functionHandle = str2func(queryString);
            for i = 1 : n
                d = obj.epochs(subSet(i));
                if functionHandle(d)
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
            functionHandle = str2func(queryString);
            tf = functionHandle(obj);
        end
        
    end
    
    methods(Access = protected)
        
        function header = getHeader(obj)
            try
                type = obj.cellType;
                if isempty(type)
                    type = 'unassigned';
                end
                header = ['Displaying information about ' type ' cell type '];
            catch
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            end
        end
        
        function groups = getPropertyGroups(obj)
            try
                attrKeys = obj.attributes.keys;
                dataSetKeys = obj.savedDataSets.keys;
                groups = matlab.mixin.util.PropertyGroup.empty(0, 2);
                
                display = struct();
                for i = 1 : numel(attrKeys)
                    display.(attrKeys{i}) = obj.attributes(attrKeys{i});
                end
                groups(1) = display;
                groups(2) = dataSetKeys;
            catch
                groups = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            end
        end
    end
    
end