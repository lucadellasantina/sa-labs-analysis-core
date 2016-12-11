classdef OnlineAnalysis < sa_labs.analysis.core.Analysis
    
    properties(Access = protected, Transient)
        epochStream
        splitParameters
        nodeId
    end
    
    methods
        
        function obj = OnlineAnalysis()
            obj@sa_labs.analysis.core.Analysis();
        end
        
        function setEpochStream(obj, epoch)
            if nargin < 2
                return
            end
            obj.epochStream = epoch;
            obj.extractor.epochStream = epoch;
        end
    end
    
    methods (Access = protected)
        
        function buildTree(obj)
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
            end
            
            if ~ present
                obj.buildBranches(obj.splitParameters(depth : end));
            end
        end
        
        function p = getSplitParameters(obj)
            p = obj.splitParameters;
        end
        
        function node = getNodes(obj, ~)
            node = obj.nodeManager.getNodes(obj.nodeId);
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
            end
        end
    end
end

