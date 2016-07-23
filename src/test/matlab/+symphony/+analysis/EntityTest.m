classdef EntityTest < matlab.unittest.TestCase
    
    properties
        seedGenerator
        epochs
    end
    
    methods (TestClassSetup)
        
        function prepareEpochData(obj)
            import symphony.analysis.core.entity.*;
            
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
    
    methods(Test)
        
        function testEpochData(obj)
            import symphony.analysis.core.entity.*;
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
        end
    end
    
    % Test methods for CellData
    
    methods(Test)
        
        function testGetEpochValues(obj)
            import symphony.analysis.core.entity.*;
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
            
            import symphony.analysis.core.entity.*;
            cellData = CellData();
            cellData.epochs = obj.epochs;
            
            [map, description] = cellData.getEpochValuesMap('intensity', 1 : 5 : 100);
            actual = sort(str2double(map.keys));
            obj.verifyEqual(actual, (10 * [1: 10]));
            expected = reshape(1 : 5 : 100, 2, 10)';
            
            for i = 1: numel(actual)
                key = num2str(actual(i));
                obj.verifyEqual(map(key), expected(i, :));
            end
            obj.verifyEqual(description, 'intensity');
            
            [map, ~] = cellData.getEpochValuesMap('unknown', 1 : 5 : 100);
            obj.verifyEmpty(map);
        end
        
    end
    
end