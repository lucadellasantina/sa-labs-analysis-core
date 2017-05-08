function finder = applyAnalysis(projectName, functions, varargin)

offlineAnalysisManager = getInstance('offlineAnalaysisManager');

ip = Inputparser();
ip.addparameter('finder', offlineAnalysisManager.getFeatureFinder(projectName), @isobject)
ip.addParameter('criteria', '', @ischar);
ip.addParameter('featureGroups', [], @isobject);
ip.parse(varargin{:})
finder = ip.Results.finder;
criteria = ip.Results.criteria;

if isempty(featureGroups) && ~ isempty(criteria)
    featureGroup = finder.findFeatureGroups(criteria);
end

finder = offlineAnalysisManager.applyAnalysis(finder, featureGroup, functions);
end

