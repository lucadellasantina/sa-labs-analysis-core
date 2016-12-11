classdef OnlineAnalysis < sa_labs.analysis.core.Analysis
    
    properties(Access = protected, Transient)
        epochStream
        splitParameters
        nodeId
    end
    
    methods(Access = protected)
        
        function buildTree(obj)
            epochParameters = obj.epochStream.parameters;
            obj.splitParameters = obj.getSplitParametersByEpoch();
            
            for depth = 1 : numel(obj.splitParameters)
                
                splitParameter = obj.splitParameters{depth};
                splitValue = epochParameters(splitParameter);
                name = [splitParameter '==' num2str(splitValue)];
                
                id = obj.nodeManager.findChild(name, obj.nodeId);
                if isempty(id)
                    break;
                end
                obj.nodeId = id;
            end
            
            if depth < numel(obj.splitParameters)
                obj.buildBranches(obj.splitParameters{depth : end});
            end
        end
        
        function setEpochStream(obj, epoch)
            if nargin < 1
                return
            end
            obj.epochStream = epoch;
            obj.extractor.epochStream = epoch;
        end
        
        function p = getSplitParameters(obj)
            p = obj.splitParameters;
        end
        
        function node = getNodes(obj, ~)
            node = obj.nodeManager.getNodes(obj.nodeId);
        end
    end
    
    methods(Access = private)
        
        function p = getSplitParametersByEpoch(obj)
            p = [];
            epochParameters = obj.epochStream.parameters;
            
            for pathIndex = 1 : obj.analysisTemplate.numberOfPaths()
                parameters = obj.analysisTemplate.getSplitParametersByPath(pathIndex);
                if all(isKey(epochParameters, parameters))
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

