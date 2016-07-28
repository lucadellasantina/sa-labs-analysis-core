classdef NodeManager < handle
    
    properties(Access = private)
        tree
    end
    
    methods
        
        function setName(obj, name)
            import symphony.analysis.core.*;
            node = entity.Node();
            node.name = name;
            obj.setnode(1, node);
        end
        
        function copyParameters(obj, id, params)
            node = obj.tree.get(id);
            node.setParameters(params);
            obj.setnode(id, node);
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
        
        function id = addNode(obj, id, splitParamName, spiltValue, epochIndices)
            
            import symphony.analysis.core.*;
            node = entity.Node();
            node.name = [splitParamName '==' spiltValue];
            node.splitParameter = splitParamName;
            node.splitValue = spiltValue;
            node.epochIndices = epochIndices;
            
            id = obj.addnode(id, node);
            node.id = id;
        end
    end
    
    methods(Access = private)
        
        function percolateUpNode(obj, nodeId, in , out)
            t = obj.tree;
            node = t.get(nodeId);
            parent = t.getparent(nodeId);
            parentNode = t.get(parent);
            
            parentNode.updateParameter(node, in, out);
            obj.setnode(parent, parentNode);
        end
        
        function setnode(obj, parent, node)
            obj.tree = obj.tree.set(parent, node);
        end
        
        function addnode(obj, id, node)
            obj.tree = obj.tree.addnode(id, node);
        end
        
        function graft(obj, index, tree2)
            obj.tree = obj.tree.graft(index, tree2);
        end
        
    end
end

