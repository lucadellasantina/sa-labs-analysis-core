classdef AnalysisTreeBuilder < handle
    
    properties(SetAccess = private)
        tree
    end
    
    methods
        
        function obj = AnalysisTreeBuilder(tree)
            if nargin < 1 
               tree = tree();
            end
            obj.tree = tree;
        end
        
        function setName(obj, name)
            nodeData = struct('name', name);
            obj.setNode(1, nodeData);
        end
        
        function buildCellTree(obj, rootNodeID, cellData, newDataSet, paramList)
            
            [epochValueMap, parameterDescription] = cellData.getEpochValuesMap(paramList{1}, newDataSet);
            uniqueValues = epochValueMap.keys;
            
            for i = 1 : length(uniqueValues)
                value = uniqueValues(i);
                newDataSet = epochValueMap(value);
                
                if ~ isempty(newDataSet)
                    nodeData = struct();
                    nodeData.splitParam = parameterDescription;
                    nodeData.name = [parameterDescription '==' value];
                    nodeData.splitValue = value;
                    nodeData.epochID = newDataSet;
                    
                    id = obj.addNode(rootNodeID, nodeData);
                    if length(paramList) > 1
                        obj.buildCellTree(id, cellData, newDataSet, paramList(2 : end));
                    end
                end
            end
        end
        
        function addTreeLevel(obj, oldTree, analysisType, param)
            childIndices = oldTree.getchildren(1);
            n = length(childIndices);
            nodeValueMap = containers.Map();
            
            for i = 1 : n
                node = oldTree.get(childIndices(i));
                if strcmp(node.class, analysisType) && isfield(node, param)
                    value = num2str(node.(param));
                    nodeValueMap = util.collections.addToMap(nodeValueMap, value, i);
                end
            end
            
            for i = 1 : numel(nodeValueMap.keys)
                value = nodeValueMap.keys(i);
                childIndicesPosition = nodeValueMap(value);
                
                obj.addNode(1, struct('name', [param '=' value], param, value));
                newChildIndices = obj.tree.getchildren(1);
                newTreeIndex = newChildIndices(i);
                obj.graftTreeByChildPositon(childIndicesPosition, childIndices, newTreeIndex, oldTree);
            end
        end
        
        function copyParameters(obj, params)
            nodeData = obj.tree.get(1);
            names = fieldnames(params);
            
            for i = 1 : length(names)
                name = names{i};
                nodeData.(name) = params.(name);
                
                if isprop(obj.tree, name)
                    obj.tree.(name) = params.(name);
                end
            end
            obj.setNode(1, nodeData);
        end
        
        function percolateUp(obj, nodeIds, varargin)
            
            if length(varargin) == 2 && iscell(varargin{1}) && iscell(varargin{2})
                inParams = varargin{1};
                outParams = varargin{2};
            else
                inParams = varargin(1 : 2 : end);
                outParams = varargin(2 : 2 : end);
            end
            
            if length(inParams) ~= length(outParams)
                error('Error: parameters must be specified in pairs');
            end
            arrayfun(@(i) obj.percolateUpByParameter(nodeIds, inParams{i}, outParams{i}),...
                1 : length(inParams));
        end
    end
    
    methods(Access = private)
        
        function percolateUpByParameter(obj, nodeIds, in , out)
            t = obj.tree;
            
            for i = 1 : length(nodeIds)
                nodeId = nodeIds(i);
                parent = t.getparent(nodeId);
                nodeData = t.get(parent);
                ref = t.get(nodeId);
                nodeData.(out) = [];
                
                if ~ isfield(ref, in)
                    continue;
                end
                
                if isstruct(ref.(in))
                    nodeData = t.updateNodeDataInStructure(nodeId, in, out);
                else
                    vector = nodeData.(out);
                    vector = [vector ref.(in)]; %#ok
                    nodeData.(out) = vector;
                end
                obj.setNode(parent, nodeData);
            end
        end
        
        function setNode(obj, parent, node)
            obj.tree = obj.tree.set(parent, node);
        end
        
        function addNode(obj, node)
            obj.tree = obj.tree.addnode(1, node);
        end
        
        function graft(obj, index, tree2)
            obj.tree = obj.tree.graft(index, tree2);
        end
        
        function graftTreeByChildPositon(poistion, childIndices, index, oldTree)
            cellfun(@(id) obj.graft(index, oldTree.subtree(childIndices(id))), poistion)
        end
    end
end

