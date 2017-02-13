classdef OnlineAnalysis < sa_labs.analysis.core.Analysis
    
    properties (Access = protected, Transient)
        epochStream
        splitParameters
        nodeId
    end
    
    properties (SetAccess = private)
        nodeIdMap
    end

    properties
        mode = sa_labs.analysis.core.AnalysisMode.ONLINE_ANALYSIS;
    end
    
    methods
        
        function obj = OnlineAnalysis(analysisProtocol, recordingLabel)
            obj@sa_labs.analysis.core.Analysis(analysisProtocol, recordingLabel);
        end
        
        function setEpochSource(obj, epoch)
            obj.state = sa_labs.analysis.app.AnalysisState.PROCESSING_STREAMS;
            obj.epochStream = epoch;
            obj.featureManager.epochStream = epoch;
        end
    end
    
    methods (Access = protected)
        
        function build(obj)
            obj.nodeIdMap = containers.Map();

            epochParameters = obj.epochStream.parameters;
            obj.splitParameters = obj.getSplitParametersByEpoch();

            obj.nodeId = 1;
            present = true;

            for depth = 1 : numel(obj.splitParameters)
                
                splitParameter = obj.splitParameters{depth};
                splitValue = epochParameters(splitParameter);
                name = [splitParameter '==' num2str(splitValue)];
                
                % possible bottle neck if nodes are > 100,000 on first
                % pause
                id = obj.featureManager.findFeatureGroupId(name, obj.nodeId);
                if isempty(id)
                    present = false;
                    break;
                end
                obj.nodeId = id;
                obj.nodeIdMap(splitParameter) = id;
            end
            
            if ~ present
                obj.add(obj.splitParameters(depth : end));
            end
        end
        
        function p = getFilterParameters(obj)
            p = obj.splitParameters;
        end
        
        function node = getFeatureGroups(obj, parameter)
            id = obj.nodeIdMap(parameter);
            node = obj.featureManager.getFeatureGroups(id);
            % disp([' [INFO] id ' num2str(id) ' parameter ' parameter]);
        end

        function copyEpochParameters(obj, nodes)
            keySet = obj.epochStream.parameters.keys;
            
            if ~ obj.featureManager.isBasicFeatureGroup(nodes)
                obj.featureManager.copyFeaturesToGroup([nodes.id], keySet, keySet);
                return
            end

            if isempty(nodes(1).parameters)
                nodes(1).setParameters(obj.epochStream.parameters);
                return
            end 
            cellfun(@(key) nodes(1).appendParameter(key, obj.epochStream.parameters(key)), keySet);
        end
    end
    
    methods (Access = private)
        
        function p = getSplitParametersByEpoch(obj)
            p = [];
            epochParameters = obj.epochStream.parameters;
            
            for pathIndex = 1 : obj.analysisProtocol.numberOfPaths()
                parameters = obj.analysisProtocol.getSplitParametersByPath(pathIndex);
                if all(ismember(parameters, epochParameters.keys))
                    p = parameters;
                    break;
                end
            end
        end
        
        function add(obj, parameters)
            EMPTY_EPOCH_INDEX = [];
            epochParameters = obj.epochStream.parameters;
            
            for i = 1 : numel(parameters)
                splitBy = parameters{i};
                splitValue = epochParameters(splitBy);
                obj.nodeId = obj.featureManager.addFeatureGroup(obj.nodeId, splitBy, splitValue, EMPTY_EPOCH_INDEX);
                
                % update node map
                obj.nodeIdMap(splitBy) = obj.nodeId;
            end
        end
    end
end

