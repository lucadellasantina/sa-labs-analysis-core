classdef Node < handle & matlab.mixin.CustomDisplay
    
    properties
        id                  % Identifier of the node, assigned by NodeManager @see NodeManager.addNode
        name                % Descriptive name of the node syntax, except root its usually [splitParameter = splitValue]
        splitParameter      % Defines level of node in tree
        splitValue          % Defines the branch of tree
        featureMap          % Feature map with key as FeatureDescription.type and value as Feature instance
        plotHandlesMap      % plot handles for set of features
        epochIndices        % List of epoch indices to be processed in Offline analysis. @see CellData and FeatureExtractor.extract
    end
    
    properties(SetAccess = private)
        parameters          % Matlab structure to store other properties and value types are scalar or cell arrays
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
        
    end
    
    methods(Access = private)
        
        function setParameter(obj, property, value)
            % setParameters - set property, value pair to parameters
            obj.parameters.(property) = value;
        end
        
    end
    
end

