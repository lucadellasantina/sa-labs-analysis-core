classdef EntityTest < matlab.unittest.TestCase
    
    properties
        seedGenerator
        epochs
    end
    
    methods (TestClassSetup)
        
        function prepareEpochData(obj)
            import sa_labs.analysis.entity.*;
            
            obj.seedGenerator = rng('default');
            noise = randn(100);
            keys = {'intensity', 'stimTime'};
            obj.epochs = EpochData.empty(0, 100);
            factor = 1;
            
            for i = 1 : 100
                e = EpochData();
                
                if mod(i, 10) == 0
                    factor = factor + 1;
                end
                e.attributes = containers.Map(keys, {factor * 10,  [num2str(factor * 20) 'ms'] });
                e.dataLinks = containers.Map({'Amp1', 'Amp2' }, {'response1', 'response2'});
                e.responseHandle = @(arg) noise;
                obj.epochs(i) = e;
            end
        end
        
    end
    % Test methods for EpochData
    
    methods(Test)
        
        function testEpochData(obj)
            import sa_labs.analysis.entity.*;
            keys = {'double', 'string', 'cell', 'array'};
            values = {20, 'abc', {'abc', 'def', 'ghi'}, [1, 2, 3, 4, 5]};
            
            epochData = EpochData();
            epochData.attributes = containers.Map(keys, values);
            epochData.parentCell = CellData();
            epochData.dataLinks = containers.Map({'Amp1', 'Amp2' }, {'response1', 'response2'});
            epochData.responseHandle = @(arg)strcat(arg, '-data');
            
            % arbitary test for attribute map
            obj.verifyEqual(epochData.get('double'), 20);
            obj.verifyEqual(epochData.get('string'), 'abc');
            obj.verifyEqual(epochData.get('cell'), {'abc', 'def', 'ghi'});
            obj.verifyEqual(epochData.get('array'), [1, 2, 3, 4, 5]);
            obj.verifyEmpty(epochData.get('unknown'));
            
            % test for epoch data behaviour
            obj.verifyEmpty(epochData.getMode('mode'));
            obj.verifyEqual(epochData.getResponse('Amp1'), 'response1-data');
            obj.verifyError(@() epochData.getResponse('unknown'), 'device:notfound');
            
            keys = {'ampMode', 'amp2Mode', 'amp3Mode'};
            values = {'cell-attached', 'cell-attached', 'whole-cell'};
            epochData.attributes = containers.Map(keys, values);
            obj.verifyEqual(sort(epochData.getMode('mode')), values);
            keys{end + 1} = 'unqiue';
            
            obj.verifyEqual(epochData.unionAttributeKeys(keys), sort(keys));
            obj.verifyEqual(sort(epochData.unionAttributeKeys([])), sort(keys(1 : end-1)));
        end
        
    end
    
    % Test methods for CellData
    
    methods(Test)
        
        function testGetEpochValues(obj)
            import sa_labs.analysis.entity.*;
            cellData = CellData();
            cellData.epochs = obj.epochs;
            
            % double as value test
            [values, description] = cellData.getEpochValues('intensity', 1 : 5 : 100);
            obj.verifyEqual(unique(values), 10 * [1: 10]);
            obj.verifyEqual(description, 'intensity');
            
            % double as value test by function handle
            [values, description] = cellData.getEpochValues(@(epoch) intensity2Rstar(epoch), 1 : 5 : 100);
            obj.verifyEqual(unique(values), 1e-2 * [ 1: 10]);
            obj.verifyEqual(description, '@(epoch)intensity2Rstar(epoch)');
            
            % string as value test
            [values, description] = cellData.getEpochValues('stimTime', 1 : 5 : 100);
            expected = arrayfun(@(i)cellstr([num2str(20 * i) 'ms' ]), 1: 10);
            obj.verifyEqual(sort(unique(values)), sort(expected));
            obj.verifyEqual(description, 'stimTime');
            
            [values, ~] = cellData.getEpochValues('unknown', 1 : 5 : 100);
            obj.verifyEmpty(values);
            
            function r_star = intensity2Rstar(epoch)
                value = epoch.get('intensity');
                r_star = value * 1e-3;
            end
        end
        
        function testGetEpochValuesMap(obj)
            
            import sa_labs.analysis.entity.*;
            cellData = CellData();
            cellData.epochs = obj.epochs;
            
            [map, description] = cellData.getEpochValuesMap('intensity', 1 : 5 : 100);
            actual = sort(str2double(map.keys));
            obj.verifyEqual(actual, (10 * [1: 10]));
            expected = reshape(1 : 5 : 100, 2, 10)';
            
            for i = 1: numel(actual)
                key = num2str(actual(i));
                obj.verifyEqual(map(key), expected(i, :)');
            end
            obj.verifyEqual(description, 'intensity');
            
            [map, ~] = cellData.getEpochValuesMap('unknown', 1 : 5 : 100);
            obj.verifyEmpty(map);
        end
        
        function testGetEpochKeysetUnion(obj)
            import sa_labs.analysis.entity.*;
            cellData = CellData();
            cellData.epochs = obj.epochs;
            
            keySet = cellData.getEpochKeysetUnion(1 : 5 : 100);
            obj.verifyEqual(keySet, {'intensity', 'stimTime'});
            
            keySet = cellData.getEpochKeysetUnion();
            obj.verifyEqual(keySet, {'intensity', 'stimTime'});
        end
        
        function testGetUniqueNonMatchingParamValues(obj)
            import sa_labs.analysis.entity.*;
            cellData = CellData();
            cellData.epochs = obj.epochs;
            
            [params, values] = cellData.getUniqueNonMatchingParamValues({'intensity'} ,1 : 5 : 100);
            obj.verifyEqual(params, {'stimTime'});
            % unique stim time @see prepareEpochData
            obj.verifyLength(values{1}, 10);
            % get the first element (value corresponds to 'stimTime') from cell array
            actual = sort(unique(values{1}));
            expected = arrayfun(@(i)cellstr([num2str(20 * i) 'ms' ]), 1: 10);
            obj.verifyEqual(actual, sort(expected));
            
            [params, values] = cellData.getUniqueNonMatchingParamValues({'intensity', 'stimTime'});
            obj.verifyEmpty(params);
            obj.verifyEmpty(values);
            
            [params, values] = cellData.getUniqueNonMatchingParamValues([] ,1 : 5 : 100);
            verify();
            [params, values] = cellData.getUniqueNonMatchingParamValues({} ,1 : 5 : 100);
            verify();
            [params, values] = cellData.getUniqueNonMatchingParamValues('unknown' ,1 : 5 : 100);
            verify();
            
            function verify()
                obj.verifyEqual(params, {'intensity', 'stimTime'});
                obj.verifyLength(values{1}, 10);
                obj.verifyLength(values{2}, 10);
                % test intensity values
                obj.verifyEqual(values{1}, (10 * [1: 10]))
                % test again stimTime values
                actualValue = sort(unique(values{2}));
                obj.verifyEqual(actualValue, sort(expected));
            end
            
            [params, values] = cellData.getUniqueParamValues(1 : 5 : 100);
            verify();
        end
        
        function testGet(obj)
            import sa_labs.analysis.entity.*;
            cellData = CellData();
            cellData.attributes = containers.Map({'other', 'string'}, {'bla', 'test'});
            cellData.tags = containers.Map('other', 'tag');
            
            obj.verifyEqual(cellData.get('other'), 'tag');
            obj.verifyEqual(cellData.get('string'), 'test');
            obj.verifyEmpty(cellData.get('unknown'));
            obj.verifyEmpty(cellData.get([]));
        end
    end
    
    % Test methods for Node
    
    methods(Test)
        
        function testParameters(obj)
            import sa_labs.analysis.entity.*;
            node = Node('root','value');
            params = struct();
            params.preTime = '500ms';
            params.epochId = {1,2};
            
            node.setParameters([]);
            obj.verifyEmpty(node.parameters);
            
            node.setParameters(params);
            obj.verifyEqual(node.parameters, params);
            
            node.appendParameter('preTime', '20ms');
            node.appendParameter('epochId', 3);
            node.appendParameter('new', {'param1', 'param2'});
            
            obj.verifyEqual(node.getParameter('epochId'), {1, 2, 3});
            obj.verifyEqual(node.getParameter('preTime'), {'500ms', '20ms'});
            obj.verifyEqual(node.getParameter('new'), {'param1', 'param2'});
            obj.verifyEmpty(node.getParameter('unknow'));
            
            node.appendParameter('new', {'param3', 'param4'});
            obj.verifyEqual(node.getParameter('new'), {'param1', 'param2', 'param3', 'param4'});
        end
        
        function testFeature(obj)
            import sa_labs.analysis.entity.*;
            node = Node('root', 'param');
            description = FeatureId.TEST_FEATURE.description;
            feature = Feature.create(description);
            node.appendFeature(feature);
            obj.verifyEmpty(feature.data);
           
            % test append data
            feature.appendData(1 : 1000);
            obj.verifyEqual(node.getFeature(description).data, 1 : 1000);
            
            % check feature as reference object
            feature.data = feature.data + ones(1,1000);
            obj.verifyEqual(node.getFeature(description).data, 2 : 1001);
            
            % scalar check
            feature.appendData(1002);
            obj.verifyEqual(node.getFeature(description).data, 2 : 1002);
            
            % vector check
            feature.appendData(1003 : 1010);
            obj.verifyEqual(node.getFeature(description).data, 2 : 1010);
            
            % adding same feature again
            node.appendFeature(feature);
            obj.verifyEqual(node.getFeature(description).data, 2 : 1010);
        end
        
        function testUpdate(obj)
            import sa_labs.analysis.entity.*;
            node = Node('Child', 'param');
            description = FeatureId.TEST_FEATURE.description;
            
            f = sa_labs.analysis.entity.Feature.create(description);
            f.data = 1 : 1000;
            node.appendFeature(f);
            
            descriptionTwo = FeatureId.TEST_SECOND_FEATURE.description;
            f2 = sa_labs.analysis.entity.Feature.create(descriptionTwo);
            f2.data = ones(1,1000);
            node.appendFeature(f2);
            
            node.appendParameter('string', 'Foo bar');
            node.appendParameter('int', 8);
            node.appendParameter('cell', {'one', 'two'});
            
            newNode = Node('Parent', 'param');
            
            newNode.appendParameter('int', 1);
            newNode.appendParameter('string', 'Foo bar');
            newNode.appendParameter('cell', {'three', 'four'});
            
            param = FeatureId.TEST_SECOND_FEATURE;
            newNode.update(node, param, param)
            
            % case 1 property check
            node.epochIndices = [1,2,3];
            newNode.update(node, 'epochIndices', 'epochIndices');
            obj.verifyEqual([newNode.epochIndices{:}], [1, 2, 3]);
            
            % case 2 epochIndices(out) and parameter(in) check
            node.appendParameter('discardedEpoch', [4, 5, 6, 7]);
            newNode.update(node, 'discardedEpoch', 'epochIndices');
            obj.verifyEqual([newNode.epochIndices{:}], 1:7);
            
            % case 3 feature map check
            obj.verifyEqual(newNode.featureMap.keys, { char(param) });
            feature = newNode.featureMap.values;
            obj.verifyEqual([feature{:}.data], ones(1,1000));
            
            obj.verifyError(@()newNode.update(node, param, FeatureId.TEST_FEATURE), 'in:out:mismatch')
            
            % case 4 name(in) and parameter(out) check
            newNode.update(node, 'name', 'cell');
            obj.verifyEqual(newNode.getParameter('cell'), {'three', 'four', 'Child==param'});
            
            % case 5 parameter check
            newNode.update(node, 'int', 'int');
            obj.verifyEqual(newNode.parameters.int, {1, 8});
            newNode.update(node, 'unknown', 'unknown');
            obj.verifyEmpty(newNode.parameters.unknown);
            
            
            % consistency check for old node
            obj.verifyEqual(node.featureMap.keys, {char(FeatureId.TEST_FEATURE), char(param)});
            features = node.featureMap.values;
            features = [features{:}];
            obj.verifyEqual([features(:).data], [(1 : 1000), ones(1,1000)]);
            
            obj.verifyError(@()newNode.update(node, 'name', 'name'),'MATLAB:class:SetProhibited');
            obj.verifyError(@()newNode.update(node, 'splitParameter', 'splitParameter'),'MATLAB:class:SetProhibited');
            obj.verifyError(@()newNode.update(node, 'splitValue', 'splitValue'),'MATLAB:class:SetProhibited');
            obj.verifyError(@()newNode.update(node, 'id', 'id'), 'id:update:prohibited');
        end
    end
    
end