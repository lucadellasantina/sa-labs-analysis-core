classdef NodeManager < handle
    
    properties(Access = protected)
        tree
    end

    properties(Dependent)
        dataStore
    end
        
    methods
        
        function obj = NodeManager(dataStore)
            if nargin < 1
                dataStore = tree();
            end
            obj.tree = dataStore;
        end
        
        function setRootName(obj, name)
            
            import sa_labs.analysis.*;
            node = entity.Node([], [], name);
            node.id = 1;
            obj.setnode(node.id, node);
        end
        
        function id = addNode(obj, id, splitParameter, spiltValue, dataSet)
            
            import sa_labs.analysis.*;
            node = entity.Node(splitParameter, spiltValue);
            
            if ~ isempty(dataSet)
                node.dataSet = dataSet;
                node.epochIndices = dataSet.epochIndices;
            end
            id = obj.addnode(id, node);
            node.id = id;
        end
        
        function removeNode(obj, id)
            if ~ isempty(obj.tree.getchildren(id))
                error('cannot remove ! node has children');
            end
            obj.tree = obj.tree.removenode(id);
            obj.updateDataStoreNodeId();
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
            nodes = obj.getNodes(indices); %#ok
        end
        
        function id = findNodeId(obj, name, nodeId)

            if nargin < 3 || isempty(nodeId)
                id = find(obj.getStructure().regexpi(['\w*' name '\w*']).treefun(@any));
                return;
            end
            subTree = obj.tree.subtree(nodeId);
            structure = subTree.treefun(@(node) node.name);
            indices = find(structure.regexpi(['\w*' name '\w*']).treefun(@any));
            
            id = arrayfun(@(index) subTree.get(index).id, indices);
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
                childNodes = obj.getNodes(childrens);
                nodes = [nodes, childNodes]; %#ok
            end
        end
        
        function append(obj, dataStore)
            obj.tree = obj.tree.graft(1, dataStore);
            obj.updateDataStoreNodeId();
        end
        
        function tree = getStructure(obj)
            tree = obj.tree.treefun(@(node) node.name);
        end

        function ds = get.dataStore(obj)
            ds = obj.tree;
        end
        
        function nodes = getNodes(obj, ids)
            nodes = arrayfun(@(index) obj.tree.get(index), ids, 'UniformOutput', false);
            nodes = [nodes{:}];
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
        
        function updateDataStoreNodeId(obj)
            for i = obj.tree.breadthfirstiterator
                if obj.tree.get(i).id ~= i
                    disp(['[INFO] updating datastore index ' num2str(i)]);
                    obj.tree.get(i).id = i;
                end
            end
        end
        
    end
end

