classdef FeatureTreeBuilder < handle
    
    properties(Access = protected)
        tree
        log
    end
    
    properties(Dependent)
        dataStore
    end
    
    methods
        
        function obj = FeatureTreeBuilder(name, value, dataTree)
            import sa_labs.analysis.*;
            
            if nargin < 3
                dataTree = tree();
            end
            obj.tree = dataTree;
            obj.setRootName(name, value);
            obj.log = logging.getLogger(app.Constants.ANALYSIS_LOGGER);
        end
        
        function setRootName(obj, name, value)
            import sa_labs.analysis.*;
            featureGroup = entity.FeatureGroup(name, value);
            featureGroup.id = 1;
            obj.setfeatureGroup(featureGroup.id, featureGroup);
        end

        function obj = set.dataStore(obj, dataTree)
            obj.tree = dataTree;
        end
        
        function ds = get.dataStore(obj)
            ds = obj.tree;
        end

        function append(obj, dataTree, copyEnabled)

            if nargin < 3
                copyEnabled = false;
            end

            % This may be a performance hit
            % Think of merging a tree in an alternative way.

            obj.tree = obj.tree.graft(1, dataTree);
            childrens = obj.tree.getchildren(1);
            obj.updateDataStoreFeatureGroupId();
            obj.log.info([ dataTree.get(1).name ' is grafted to parant tree '])

            if copyEnabled
                id = childrens(end);
                group = obj.getFeatureGroups(id);
                parent = obj.getFeatureGroups(1);
                obj.log.debug([' analysis parameter from [ ' group.name ' ] is pushed to [ ' parent.name ' ]'])
                parent.setParameters(group.parameters);
            end
        end

        
        function [id, featureGroup] = addFeatureGroup(obj, id, splitParameter, spiltValue, epochGroup)
            
            import sa_labs.analysis.*;
            featureGroup = entity.FeatureGroup(splitParameter, spiltValue);
            
            if ~ isempty(epochGroup)
                featureGroup.epochGroup = epochGroup;
                featureGroup.epochIndices = epochGroup.epochIndices;
            end
            id = obj.addfeatureGroup(id, featureGroup);
            featureGroup.id = id;
            obj.log.trace(['feature group [ ' featureGroup.name ' ] is added at the id [ ' num2str(id) ' ]'])
        end
        
        function collect(obj, featureGroupIds, varargin)
            
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
        
        function curateDataStore(obj)
            ids = obj.tree.treefun(@(node) obj.isFeatureGroupAlreadyPresent(node.id)).find();
            
            while ~ isempty(ids)
                id = ids(1);
                obj.tree = obj.tree.removenode(id);
                obj.updateDataStoreFeatureGroupId();
                ids = obj.tree.treefun(@(node) obj.isFeatureGroupAlreadyPresent(node.id)).find();
            end
        end
        
        function tf = isFeatureGroupAlreadyPresent(obj, sourceId)
            siblings = obj.tree.getsiblings(sourceId);
            ids = siblings(siblings ~= sourceId);
            sourceGroup = obj.getFeatureGroups(sourceId);
           
            tf = ~ isempty(ids) &&...
                any(arrayfun(@(id) strcmp(obj.getFeatureGroups(id).name, sourceGroup.name), ids))...
                && obj.isBasicFeatureGroup(sourceGroup);
        end
        
        function tf = isPresent(obj, id)
            tf = obj.tree.treefun(@(node) node.id == id).any();
        end

        function tf = isBasicFeatureGroup(obj, featureGroups)
            tf = ~ isempty(featureGroups) && all(ismember([featureGroups.id], obj.tree.findleaves)) == 1;
        end
        
        function tree = getStructure(obj)
            tree = obj.tree.treefun(@(featureGroup) strcat(featureGroup.name, ' (' , num2str(featureGroup.id), ') '));
        end
        
        function featureGroups = getFeatureGroups(obj, ids)
            featureGroups = arrayfun(@(index) obj.tree.get(index), ids, 'UniformOutput', false);
            featureGroups = [featureGroups{:}];
        end
                
        % TODO move all find functions to visitor

        function featureGroups = find(obj, name, varargin)
            ip = inputParser;
            ip.addParameter('has', []);
            ip.parse(varargin{:});
            has = ip.Results.has;
            
            featureGroups = []; 
            if isempty(has)
                featureGroups = obj.findFeatureGroup(name);
                return;
            end
            
            for i = obj.tree.findpath(has.id, 1)
                if regexp(obj.tree.get(i).name, ['\w*' name '\w*' ])
                    featureGroups = obj.tree.get(i);
                    break;
                end
            end
        end
        
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
        
        
        function percolateUpFeatureGroup(obj, featureGroupId, in , out)
            t = obj.tree;
            featureGroup = t.get(featureGroupId);
            parent = t.getparent(featureGroupId);
            parentFeatureGroup = t.get(parent);
            parentFeatureGroup.update(featureGroup, in, out);
            obj.setfeatureGroup(parent, parentFeatureGroup);
            info = ['pushing [ ' in ' ] from feature group [ ' featureGroup.name ' ] to parent [ ' parentFeatureGroup.name ' ]'];
            obj.log.trace(info)
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
                    obj.log.trace(['updating tree index [ ' num2str(i) ' ]'])
                    obj.tree.get(i).id = i;
                end
            end
        end
    end
end

