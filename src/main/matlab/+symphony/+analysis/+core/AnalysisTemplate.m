classdef AnalysisTemplate < handle
    
    % AnalysisTemplate contains information about split parameters, split
    % values and extractor functions at the specified tree level
    
    properties(Access = private)
        structure           % Structure from user interface or yaml
        functionContext     % Map containing key as split parameter and value as extractor functions
    end
    
    properties(Dependent)
        copyParameters      % List of unique-paramters to copied from epoch to node
        splitParameters     % Defines the level in analysis tree
        type                % Type of analysis
    end
    
    methods
        
        function obj = AnalysisTemplate(structure)
            obj.structure = structure;
            obj.populateFunctionContext();
        end
        
        function values = validateLevel(obj, level, parameter, values)
            
            % Description - Takes the tree level, split parameter and split
            % value from build tree of analysis class. It validates those
            % parameter with actual analysis template structure
            %
            % returns - array / cell array of value(s)
            
            if level ~= find(ismember(obj.splitParameters, parameter));
                throw(symphony.analysis.app.Exceptions.INVALID_LEVEL.create());
            end
            templateValues = obj.getSplitValue(parameter);
            
            if ischar(values)
                values = {values};
            elseif isnumeric(values)
                templateValues = cell2mat(templateValues);
            end
            
            if isempty(templateValues)
                return
            end
            found = ismember(templateValues, values);
            
            if sum(found) == 0
                throw(symphony.analysis.app.Exceptions.SPLIT_VALUE_NOT_FOUND.create());
            end
            values = templateValues(found);
        end
        
        function f = getExtractorFunctions(obj, parameter)
            
            % returns - extractor function for given parameter if parameter
            % not found returns empty
            
            f = [];
            
            if isKey(obj.functionContext, parameter)
                f = obj.functionContext(parameter);
            end
        end
        
        function p = get.copyParameters(obj)
            p = obj.structure.(symphony.analysis.app.Constants.TEMPLATE_COPY_PARAMETERS);
        end
        
        function p = get.splitParameters(obj)
            p = obj.structure.(symphony.analysis.app.Constants.TEMPLATE_BUILD_TREE_BY);
        end
        
        function p = get.type(obj)
            p = obj.structure.(symphony.analysis.app.Constants.TEMPLATE_TYPE)
        end
        
        function v = getSplitValue(obj, parameter)
            
            % returns - array / cell array of split values for given split parameter
            % It returns empty
            %   1. If parameter is not defined in template structure
            %   2. If template structure does not have splitValue
            %   3. If split value is a function handle
            
            v = [];
            if ~ isfield(obj.structure, parameter)
                return
            end
            
            split = obj.structure.(parameter);
            desc = symphony.analysis.app.Constants.TEMPLATE_SPLIT_VALUE;
            
            if ~ isfield(split, desc) || isempty(split.(desc)) || ...
                    (ischar(split.(desc)) && ~ isempty((strfind(split.(desc), '@')) == 1)) % check for function handle
                return
            end
            v = split.(desc);
            
            if ischar(v)
                v = {v};
            end
            
        end
    end
    
    methods(Access = private)
        
        function populateFunctionContext(obj)
            parameters = obj.splitParameters;
            desc = symphony.analysis.app.Constants.TEMPLATE_FEATURE_EXTRACTOR;
            obj.functionContext = containers.Map();
            
            for i = 1 : numel(parameters)
                p = parameters{i};
                if isfield(obj.structure, p) && isfield(obj.structure.(p), desc)
                    obj.functionContext(p) = obj.structure.(p).(desc);
                end
            end
        end
        
    end
    
end

