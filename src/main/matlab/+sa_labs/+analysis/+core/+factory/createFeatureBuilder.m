function obj = createFeatureBuilder(varargin)

	ip = inputParser;
    ip.KeepUnmatched = true;
	ip.addRequired('name', @ischar);
	ip.addRequired('value', @ischar);
	ip.addParameter('class', 'sa_labs.analysis.core.FeatureTreeBuilder', @ischar);
	ip.parse(varargin{:});
	class = ip.Results.class;

	switch class
	    
	    case 'sa_labs.analysis.core.FeatureTreeBuilder'
	        ip.addParameter('data', tree(), @(data) validateTreeData(data));
	        ip.addParameter('copyParameters', false, @islogical);
	        
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

    obj = constructor(name, value);
    for tree = dataTrees
        if tree.depth > 0
            obj.append(tree, params.copyParameters);
        end
    end
end

function tf = validateTreeData(data)
    tf = all( arrayfun(@(t) strcmp(class(t), 'tree'), data));
end