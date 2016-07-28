classdef Node < handle & matlab.mixin.CustomDisplay
    
    properties
        id                  % Identifier of the node, assigned by NodeManager @see NodeManager.addNode
        name                % Descriptive name of the node, except root its usually of format [splitParameter = splitValue]
        splitParameter      % Defines level of node in tree
        splitValue          % Defines the branch of tree
        featureMap          % Feature map with key as FeatureDescription.type and value as @see Feature instance
        plotHandlesMap      % plot handles for set of features
        epochIndices        % List of epoch indices to be processed in Offline analysis. @see CellData and FeatureExtractor.extract
    end
    
    properties(SetAccess = private)
        parameters          % Matlab structure to store other properties and value (types are scalar or cell arrays)
    end
    
    methods
        
        function obj = Node()
            obj.featureMap = containers.Map();
            obj.plotHandlesMap = containers.Map();
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
            new = symphony.analysis.util.collections.addToCell(old, value);
            obj.setParameter(key, new);
        end
        
        function feature = getFeature(obj, featureDescription)
            
            % getFeature - returns the feature based on FeatureDescription
            % implementaion reference
            key = char(featureDescription.type);
            
            feature = [];
            if isKey(obj.featureMap, key)
                feature = obj.featureMap(key);
            end
        end
        
        function feature = appendFeature(obj, featureDescription, value)
            
            % appendFeature - appends the sclar or vector of values to
            % feature.data
            % feature.data has support for arrays and not cell arrays
            
            key = char(featureDescription.type);
            feature = obj.getFeature(featureDescription);
            
            if isempty(feature)
                feature = symphony.analysis.core.entity.Feature.create(featureDescription);
                obj.featureMap(key) = feature;
            end
            
            if isscalar(value)
                feature.data(end + 1) = value;
            else
                feature.data = [feature.data, value];
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
            
            % safe casting
            in = char(in);
            out = char(out);
            
            % case 1 - node.in and obj.out is present has properties 
            if isprop(obj, out) && isprop(node, in)
                old = obj.(out);
                obj.(out) = symphony.analysis.util.collections.addToCell(old, node.(in));
                return
                
            end
            % case 2 - node.in is struct parameters & obj.out is class property
            if isprop(obj, out)
                old = obj.(out);
                obj.(out) = symphony.analysis.util.collections.addToCell(old, node.getParameter(in));
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
                
                feature = node.featureMap(in);
                obj.appendFeature(feature.description, feature.data);
                return
            end
         
            % case 5 just append the in to out struct parameters
            % for unknown in parameters, it creates empty out paramters
            obj.appendParameter(out, node.getParameter(in));
        end
    end
    
    methods(Access = private)
        
        function setParameter(obj, property, value)
            % setParameters - set property, value pair to parameters
            obj.parameters.(property) = value;
        end
        
    end
    
end

