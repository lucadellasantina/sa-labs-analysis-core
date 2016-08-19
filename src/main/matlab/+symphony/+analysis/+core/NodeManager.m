classdef NodeManager < handle
    
    properties(SetAccess = protected)
        tree
    end
    
    
    methods
        
        function obj = NodeManager(tree)
            obj.tree = tree;
        end
        
        function setRootName(obj, name)
            
            import symphony.analysis.*;
            node = entity.Node([], [], name);
            node.id = 1;
            obj.setnode(node.id, node);
        end
        
        function id = addNode(obj, id, splitParameter, spiltValue, epochIndices)
            
            import symphony.analysis.*;
            node = entity.Node(splitParameter, spiltValue);
            node.epochIndices = epochIndices;
            node.epochIndicesCache = epochIndices;
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
        
        % TODO move all find functions to visitor
        function nodes = findNodesByName(obj, name)
            nodes = [];
            
            if isempty(name)
                return
            end
            indices = find(obj.getStructure().regexpi(['\w*' name '\w*']).treefun(@any));
            
            nodes = symphony.analysis.entity.Node.empty(0, numel(indices));
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
        
        function appendToRoot(obj, tree2)
            obj.tree = obj.tree.graft(1, tree2);
        end
        
        function tree = getStructure(obj)
            tree = obj.tree.treefun(@(node) node.name);
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

        end
        
        function id = addnode(obj, id, node)
            [obj.tree, id] = obj.tree.addnode(id, node);
        end
        
    end
end

