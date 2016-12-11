classdef Node < handle & matlab.mixin.CustomDisplay
    
    properties
        id                  % Identifier of the node, assigned by NodeManager @see NodeManager.addNode
        dataSet             % Read only dataSet and used as cache
    end
    
    properties(SetAccess = immutable)
        name                % Descriptive name of the node, except root its usually of format [splitParameter = splitValue]
        splitParameter      % Defines level of node in tree
        splitValue          % Defines the branch of tree
    end
    
    properties(SetAccess = private)
        parameters          % Matlab structure to store other properties and value (types are scalar or cell arrays)
    end
    
    properties
        featureMap          % Feature map with key as FeatureDescription.type and value as @see Feature instance
        epochIndices        % List of epoch indices to be processed in Offline analysis. @see CellData and FeatureExtractor.extract
    end
    
    methods
        
        function obj = Node(splitParameter, splitValue, name)
            if nargin < 3
                name = [splitParameter '==' num2str(splitValue)];
            end
            
            obj.featureMap = containers.Map();
            obj.name = name;
            obj.splitParameter = splitParameter;
            obj.splitValue = splitValue;
        end
        
        function setParameters(obj, parameters)
            
            % setParameters - Copies from parameters to obj.parameters
            % @see setParameter
            
            if isempty(parameters)
                return
            end
            names = fieldnames(parameters);
            
            for i = 1 : length(names)
                obj.setParameter(names{i}, parameters.(names{i}));
            end
        end
        
        function value = getParameter(obj, property)
            
            % getParameter - get the value from obj.parameters for
            % given property
            % Return data type of value is scalar or cell array
            
            value = [];
            if  isfield(obj.parameters, property)
                value = obj.parameters.(property);
            end
        end
        
        function appendParameter(obj, key, value)
            
            % append key, value pair to obj.parameters. On empty field it
            % creates the new field,value else it appends to existing value
            % @see setParameter
            
            old = obj.getParameter(key);
            
            if isempty(old)
                obj.setParameter(key, value);
                return
            end
            new = sa_labs.analysis.util.collections.addToCell(old, value);
            obj.setParameter(key, new);
        end
        
        function appendFeature(obj, feature)
            
            f = obj.getFeature([feature.description]);
            
            if isequal(f, feature)
                return;
            end
            key = char(f.description.type);
            obj.featureMap = sa_labs.analysis.util.collections.addToMap(obj.featureMap, key, feature);
        end
        
        function feature = getFeature(obj, featureDescription)
            
            % getFeature - returns the feature based on FeatureDescription
            % reference
            type = unique([featureDescription.type]);
            
            if numel(type) > 1
                error('cannot retrive multiple features ! Check the featureDescription.type')
            end
            
            key = char(type);
            
            if isKey(obj.featureMap, key)
                feature = obj.featureMap(key);
            else
                feature = sa_labs.analysis.entity.Feature.create(featureDescription(1));
                obj.featureMap(key) = feature;
            end
        end
        
        function update(obj, node, in, out)
            
            % Generic code to handle merge from source node to destination
            % obj(node). It merges following,
            %
            %   1. properties
            %   2. Feature
            %   3. parameters 'matlab structure'
            %
            % arguments
            % node - source node
            % in  - It may be one of source node property, parameter and feature
            % out - It may be one of destination obj(node) property, parameter and feature
            
            import sa_labs.analysis.util.collections.*;
            % safe casting
            
            if nargin < 4
                out = in;
            end
            
            in = char(in);
            out = char(out);
            
            if strcmp(out, 'id')
                error('id:update:prohibited', 'cannot updated instance id');
            end
            
            % case 1 - node.in and obj.out is present has properties
            if isprop(obj, out) && isprop(node, in)
                old = obj.(out);
                obj.(out) = addToCell(old, node.(in));
                return
                
            end
            % case 2 - node.in is struct parameters & obj.out is class property
            if isprop(obj, out)
                old = obj.(out);
                obj.(out) = addToCell(old, node.getParameter(in));
                return
            end
            
            % case 3 node.in is class property but obj.out is struct
            % parameters
            if isprop(node, in)
                obj.appendParameter(out, node.(in));
                return
            end
            
            % case 4 in == out and its a key of featureMap
            keys = node.featureMap.keys;
            if ismember(in, keys)
                
                if ~ strcmp(in, out)
                    error('in:out:mismatch', 'In and out should be same for appending feature map')
                end
                obj.appendFeature(node.featureMap(in))
                return
            end
            
            % case 5 just append the in to out struct parameters
            % for unknown in parameters, it creates empty out paramters
            obj.appendParameter(out, node.getParameter(in));
        end
        
        function keySet = getFeatureKey(obj)
            if numel(obj) > 1
                result = arrayfun(@(ref) ref.featureMap.keys, obj, 'UniformOutput', false);
                keySet = unique([result{:}]);
                return
            end
            keySet = obj.featureMap.keys;
        end
    end
    
    methods(Access = private)
        
        function setParameter(obj, property, value)
            % setParameters - set property, value pair to parameters
            obj.parameters.(property) = value;
        end
        
    end
    
end

