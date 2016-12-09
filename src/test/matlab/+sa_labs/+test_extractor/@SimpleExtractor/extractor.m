function extractor(obj, node, varargin)

    ip = inputParser;
    ip.addParameter('param1', 'err', @ischar);
    ip.addParameter('param2', 'err', @ischar);
    ip.parse(varargin{:});

    obj.testInstance.verifyEqual(ip.Results.param1, 'value1');
    obj.testInstance.verifyEqual(ip.Results.param2, 'value2');
    obj.testInstance.verifyEqual(node.splitParameter, 'testNode');

    obj.callstack = obj.callstack + 1;
end