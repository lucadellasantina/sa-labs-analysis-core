classdef FeatureTreeFinder < handle
    
    properties (Access = protected)
        tree
        log
    end
    
    methods
        
        function obj = FeatureTreeFinder(dataTree)
            obj.tree = dataTree;
            obj.log = logging.getLogger(sa_labs.analysis.app.Constants.ANALYSIS_LOGGER);
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
        
        function query = find(obj, name, varargin)
            ip = inputParser;
            ip.addParameter('hasParent', []);
            ip.parse(varargin{:});
            hasParent = ip.Results.hasParent;
            
            featureGroups = [];
            parentGroups = obj.findFeatureGroup(hasParent);

            if all(isempty(parentGroups))
                query = linq(obj.findFeatureGroup(name));
                return;
            end
            indices = [];
            for id = [parentGroups(:).id]
                indices = [indices, obj.findFeatureGroupId(name, id)]; %#ok;
            end
            featureGroups = obj.getFeatureGroups(indices);
            query = linq(featureGroups);
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
    
end

