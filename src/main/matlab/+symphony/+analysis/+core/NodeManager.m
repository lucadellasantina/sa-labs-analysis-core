classdef NodeManager < handle
    
    properties(Access = private, SetObservable)
        tree
    end
    
    properties(SetAccess = private)
        searchIndex
        featureIndex
    end
    
    methods
        
        function obj = NodeManager(tree)
            obj.tree = tree;
            obj.searchIndex = tree();
            obj.featureIndex = tree();
        end
        
        function setName(obj, name)
            import symphony.analysis.core.*;
            node = entity.Node();
            node.name = name;
            obj.setnode(1, node);
        end
        
        function id = addNode(obj, id, splitParamName, spiltValue, epochIndices)
            
            import symphony.analysis.*;
            node = core.entity.Node();
            node.name = [splitParamName '==' spiltValue];
            node.splitParameter = splitParamName;
            node.splitValue = spiltValue;
            node.epochIndices = epochIndices;
            
            id = obj.addnode(id, node);
            node.id = id;
        end
        
        function percolateUp(obj, nodeIds, varargin)
            
            if length(varargin) == 2 && iscell(varargin{1}) && iscell(varargin{2})
                inParameters = varargin{1};
                outParameters = varargin{2};
            else
                inParameters = varargin(1 : 2 : end);
                outParameters = varargin(2 : 2 : end);
            end
            n = length(inParameters) ;
            
            if n ~= length(outParameters)
                error('Error: parameters must be specified in pairs');
            end
            
            byNodes = @(in, out) arrayfun(@(nodeId) obj.percolateUpNode(nodeId, in ,out), nodeIds);
            arrayfun(@(i) byNodes(inParameters{i}, outParameters{i}), 1 : n);
        end
        
        function nodes = findNodesByName(obj, name)
            indices = find(obj.searchIndex.strncmp(name, numel(name)));
            
            nodes = symphony.analysis.core.entity.Node.empty(0, numel(indices));
            for i = 1 : numel(indices)
                nodes(i) = obj.tree.get(indices(i));
            end
        end
        
        function nodes = getAllChildrensByName(obj, regexp)
            nodesByName = obj.findNodesByName(regexp);
            nodes = [];
            
            for i = 1 : numel(nodesByName)
                node = nodesByName(i);
                subTree = obj.tree.subtree(node.id);
                childNodes = arrayfun(@(index) subTree.get(index), subTree.depthfirstiterator, 'UniformOutput', false);
                nodes = [nodes, childNodes{:}]; %#ok
            end
        end
        
        function nodes = getImmediateChildrensByName(obj, regexp)
            nodesByName = obj.findNodesByName(regexp);
            nodes = [];
            
            for i = 1 : numel(nodesByName)
                node = nodesByName(i);
                childrens = obj.tree.getchildren(node.id);
                childNodes = arrayfun(@(index) obj.tree.get(index), childrens, 'UniformOutput', false);
                nodes = [nodes, childNodes{:}]; %#ok
            end
        end
        
    end
    
    methods(Access = private)
        
        function percolateUpNode(obj, nodeId, in , out)
            t = obj.tree;
            node = t.get(nodeId);
            parent = t.getparent(nodeId);
            parentNode = t.get(parent);
            
            parentNode.update(node, in, out);
            obj.setnode(parent, parentNode);
        end
        
        function setnode(obj, parent, node)
            obj.tree = obj.tree.set(parent, node);
            obj.searchIndex = obj.searchIndex.set(parent, node.name);
        end
        
        function id = addnode(obj, id, node)
            obj.searchIndex = obj.searchIndex.addnode(id, node.name);
            [obj.tree, id] = obj.tree.addnode(id, node);
        end
        
        function graft(obj, index, tree2)
            obj.tree = obj.tree.graft(index, tree2);
        end
    
    end
end

