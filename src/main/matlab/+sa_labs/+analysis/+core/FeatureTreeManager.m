classdef FeatureTreeManager < sa_labs.analysis.core.FeatureManager
    
    properties(Access = protected)
        tree
    end
    
    properties(Dependent)
        dataStore
    end
    
    methods
        
        function obj = FeatureTreeManager(analysisProtocol, analysisMode, dataStore)
            if isempty(dataStore)
                dataStore = tree();
            end
            obj@sa_labs.analysis.core.FeatureManager(analysisProtocol, analysisMode, dataStore);
            obj.setRootName(analysisProtocol.type);
        end
        
        function obj = set.dataStore(obj, tree)
            obj.tree = tree;
        end
        
        % This may be a performance hit
        % Think of merging a tree in an alternative way.
        
        function append(obj, dataStore)
            obj.tree = obj.tree.graft(1, dataStore);
            obj.updateDataStoreFeatureGroupId();
        end
        
        function ds = get.dataStore(obj)
            ds = obj.tree;
        end
        
        function id = addFeatureGroup(obj, id, splitParameter, spiltValue, epochGroup)
            
            import sa_labs.analysis.*;
            featureGroup = entity.FeatureGroup(splitParameter, spiltValue);
            
            if ~ isempty(epochGroup)
                featureGroup.epochGroup = epochGroup;
                featureGroup.epochIndices = epochGroup.epochIndices;
            end
            id = obj.addfeatureGroup(id, featureGroup);
            featureGroup.id = id;
        end
        
        function copyFeaturesToGroup(obj, featureGroupIds, varargin)
            
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
            
            copy = @(in, out) arrayfun(@(id) obj.percolateUpFeatureGroup(id, in ,out), featureGroupIds);
            arrayfun(@(i) copy(inParameters{i}, outParameters{i}), 1 : n);
        end
        
        function removeFeatureGroup(obj, id)
            if ~ isempty(obj.tree.getchildren(id))
                error('cannot remove ! featureGroup has children');
            end
            obj.tree = obj.tree.removenode(id);
            obj.updateDataStoreFeatureGroupId();
        end
        
        function tree = getStructure(obj)
            tree = obj.tree.treefun(@(featureGroup) strcat(featureGroup.name, ' (' , num2str(featureGroup.id), ') '));
        end
        
        function featureGroups = getFeatureGroups(obj, ids)
            featureGroups = arrayfun(@(index) obj.tree.get(index), ids, 'UniformOutput', false);
            featureGroups = [featureGroups{:}];
        end
        
        function tf = isBasicFeatureGroup(obj, featureGroups)
            tf = ~ isempty(featureGroups) && all(ismember([featureGroups.id], obj.tree.findleaves)) == 1;
        end
        
        % TODO move all find functions to visitor
        
        function featureGroups = findFeatureGroup(obj, name)
            featureGroups = [];
            
            if isempty(name)
                return
            end
            indices = find(obj.getStructure().regexp(['\w*' name '\w*']).treefun(@any));
            featureGroups = obj.getFeatureGroups(indices); %#ok
        end
        
        function id = findFeatureGroupId(obj, name, featureGroupId)
            
            if nargin < 3 || isempty(featureGroupId)
                id = find(obj.getStructure().regexp(['\w*' name '\w*']).treefun(@any));
                return;
            end
            subTree = obj.tree.subtree(featureGroupId);
            structure = subTree.treefun(@(featureGroup) featureGroup.name);
            indices = find(structure.regexp(['\w*' name '\w*']).treefun(@any));
            
            id = arrayfun(@(index) subTree.get(index).id, indices);
        end
        
        function featureGroups = getAllChildrensByName(obj, regexp)
            featureGroupsByName = obj.findFeatureGroup(regexp);
            featureGroups = [];
            
            for i = 1 : numel(featureGroupsByName)
                featureGroup = featureGroupsByName(i);
                subTree = obj.tree.subtree(featureGroup.id);
                childFeatureGroups = arrayfun(@(index) subTree.get(index), subTree.depthfirstiterator, 'UniformOutput', false);
                featureGroups = [featureGroups, childFeatureGroups{:}]; %#ok
            end
        end
        
        function featureGroups = getImmediateChildrensByName(obj, regexp)
            featureGroupsByName = obj.findFeatureGroup(regexp);
            featureGroups = [];
            
            for i = 1 : numel(featureGroupsByName)
                featureGroup = featureGroupsByName(i);
                childrens = obj.tree.getchildren(featureGroup.id);
                childFeatureGroups = obj.getFeatureGroups(childrens);
                featureGroups = [featureGroups, childFeatureGroups]; %#ok
            end
        end
    end
    
    methods(Access = private)
        
        function setRootName(obj, name)
            
            import sa_labs.analysis.*;
            featureGroup = entity.FeatureGroup([], [], name);
            featureGroup.id = 1;
            obj.setfeatureGroup(featureGroup.id, featureGroup);
        end
        
        function percolateUpFeatureGroup(obj, featureGroupId, in , out)
            t = obj.tree;
            featureGroup = t.get(featureGroupId);
            parent = t.getparent(featureGroupId);
            parentFeatureGroup = t.get(parent);
            
            parentFeatureGroup.update(featureGroup, in, out);
            obj.setfeatureGroup(parent, parentFeatureGroup);
        end
        
        function setfeatureGroup(obj, parent, featureGroup)
            obj.tree = obj.tree.set(parent, featureGroup);
            
        end
        
        function id = addfeatureGroup(obj, id, featureGroup)
            [obj.tree, id] = obj.tree.addnode(id, featureGroup);
        end
        
        function updateDataStoreFeatureGroupId(obj)
            for i = obj.tree.breadthfirstiterator
                if obj.tree.get(i).id ~= i
                    % disp(['[INFO] updating datastore index ' num2str(i)]);
                    obj.tree.get(i).id = i;
                end
            end
        end
    end
end

