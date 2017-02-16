function obj = createFeatureBuilder(varargin)

	ip = inputParser;
	ip.addRequired('name', @ischar);
	ip.addRequired('value', @ischar);
	ip.addParameter('class', 'sa_labs.analysis.core.FeatureTreeBuilder', @ischar);
	ip.parse(varargin{:});
	class = ip.Results.class;

	switch class
	    
	    case 'sa_labs.analysis.core.FeatureTreeBuilder'
	        ip.addOptional('data', tree(), @(x) all(is(x, 'tree')));
	        ip.addOptional('copyParameters', false, @islogical);
	        
	        ip.parse(varargin{:});
	        obj = createFeatureTreeBuilder(ip.Results);
	        
	end
end

function obj = createFeatureTreeBuilder(params)

	class = params.class;
	name = params.name;
	value = params.value;
	dataTrees = params.data;
	constructor = str2func(class);

	if numel(dataTrees) == 1
	    obj = constructor(name, value, dataTrees);
	    return
	end

	obj = constructor(name, value);
	for tree = dataTrees
	    obj.append(tree, params.copyParameters);
	end
end