function obj = createFeatureBuilder(varargin)

ip = inputParser;
ip.addParameter('class', 'sa_labs.analysis.core.FeatureTreeBuilder', @ischar);
ip.addParameter('name', 'unknownn', @ischar);
ip.addParameter('value', 'unknownn', @ischar);

ip.parse(varargin{:});

class = ip.Results.class;
name = ip.Results.name;
value = ip.Results.value;

constructor = str2func(class);
obj = constructor(name, value);

end

