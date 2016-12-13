classdef OnlineAnalysis < sa_labs.analysis.core.Analysis
    
    properties(Access = protected, Transient)
        epochStream
        splitParameters
        nodeId
        nodeIdMap
    end
    
    methods
        
        function obj = OnlineAnalysis()
            obj@sa_labs.analysis.core.Analysis();
        end
        
        function setEpochSource(obj, epoch)
            if nargin < 2
                return
            end
            obj.epochStream = epoch;
            obj.extractor.epochStream = epoch;
        end
    end
    
    methods (Access = protected)
        
        function buildTree(obj)
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
                id = obj.nodeManager.findNodeId(name, obj.nodeId);
                if isempty(id)
                    present = false;
                    break;
                end
                obj.nodeId = id;
                obj.nodeIdMap(splitParameter) = id;
            end
            
            if ~ present
                obj.buildBranches(obj.splitParameters(depth : end));
            end
        end
        
        function p = getSplitParameters(obj)
            p = obj.splitParameters;
        end
        
        function node = getNodes(obj, parameter)
            id = obj.nodeIdMap(parameter);
            node = obj.nodeManager.getNodes(id);
        end

        function updateEpochParameters(obj, nodes)
            keySet = obj.epochStream.parameters.keys;
            
            if ~ obj.nodeManager.isLeaf(nodes)
                obj.nodeManager.percolateUp([nodes.id], keySet, keySet);
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
            
            for pathIndex = 1 : obj.analysisTemplate.numberOfPaths()
                parameters = obj.analysisTemplate.getSplitParametersByPath(pathIndex);
                if all(ismember(parameters, epochParameters.keys))
                    p = parameters;
                    break;
                end
            end
        end
        
        function buildBranches(obj, parameters)
            EMPTY_DATASET = [];
            epochParameters = obj.epochStream.parameters;
            
            for i = 1 : numel(parameters)
                splitBy = parameters{i};
                splitValue = epochParameters(splitBy);
                obj.nodeId = obj.nodeManager.addNode(obj.nodeId, splitBy, splitValue, EMPTY_DATASET);
                
                % update node map
                obj.nodeIdMap(splitBy) = obj.nodeId;
            end
        end
    end
end

