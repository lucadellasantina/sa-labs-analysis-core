classdef AnalysisTreeBuilder < handle
    
    properties(SetAccess = private)
        tree
    end
    
    methods
        
        function obj = AnalysisTreeBuilder(tree)
            obj.tree = tree;
        end
        
        function setName(obj, name)
            nodeData = struct('name', name);
            obj.setNode(1, nodeData);
        end
        
        function buildCellTree(obj, rootNodeID, cellData, dataSet, paramList)
            
            values = cellData.getEpochVals(paramList{1}, dataSet);
            parameter = paramList{1};
            uniqueValues = unique(values);
            
            for i = 1 : length(uniqueValues)
                newDataSet = cellData.filter(dataSet, values, uniqueValues(i));
                
                if ~ isempty(newDataSet)
                    nodeData = struct();
                    nodeData.splitParam = parameter;
                    nodeData.name = [parameter '==' num2str(value)];
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
                valueIndices = nodeValueMap(value);
                
                obj.addNode(1, struct('name', [param '=' value], param, value));
                newChildIndices = obj.tree.getchildren(1);
                newTree = newChildIndices(i);
                
                cellfun(@(index) obj.graft(newTree, oldTree.subtree(childIndices(index))), valueIndices)
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
            obj.setNode(nodeData);
        end
        
        function percolateUp(obj)
            % TODO
        end
        
    end
    
    methods(Access = private)
        
        function setNode(obj, node)
            obj.tree = obj.tree.set(1, node);
        end
        
        function addNode(obj, node)
            obj.tree = obj.tree.addnode(1, node);
        end
        
        function graft(obj, tree1, tree2)
            obj.tree = obj.tree.graft(tree1, tree2);
        end
    end
end

