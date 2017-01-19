classdef FeatureExtractor < handle
    
    properties
        nodeManager
        epochStream
        descriptionMap
    end
    
    properties (Constant)
        CLASS = 'sa_labs.analysis.core.FeatureExtractor';
        FORMAT_SPECIFIER = '%s%s%s%s%s%s%s%[^\n\r]';
    end
    
    methods
        
        function loadFeatureDescription(obj, descriptionFile)
            import sa_labs.analysis.*;
            
            if ~ isempty(obj.descriptionMap)
                warning(['reloading descriptionMap from file ' descriptionFile])
            end
            text = obj.readCSV(descriptionFile);
            
            % get the first column and use it as key for descriptionMap
            vars = text(:, 1);
            header = text(1, :);
            obj.descriptionMap = containers.Map();
            
            % skip the header rows
            for i = 2 : numel(vars)
                key = strtrim(vars{i});
                desc = entity.FeatureDescription(containers.Map(header, text(i, :)));
                obj.descriptionMap(key) = desc;
            end
        end
        
        function text = readCSV(obj, fname)
            
            % Format specifier description
            % ----------------------------------------------------------------------------
            % 'id', 'description', 'strategy', 'unit', 'chartType', 'xAxis', 'properties'    
            % ----------------------------------------------------------------------------  
            
            fid = fopen(fname, 'r');
            text = textscan(fid, obj.FORMAT_SPECIFIER, 'Delimiter', ',');
            % unwrap cell array to array
            text =  [text{1, :}];
            columns = find(~ cellfun(@isempty, text(1, :)));
            text = text(:, columns); 
            fclose(fid);
        end
        
        function delegate(obj, extractorFunctions, nodes)
            
            for i = 1 : numel(extractorFunctions)
                func = str2func(extractorFunctions{i});
                
                arrayfun(@(node) func(obj, node), nodes)
                featureKeySet = nodes.getFeatureKey();
                obj.nodeManager.percolateUp([nodes.id], featureKeySet, featureKeySet);
            end
        end
        
        function response = getBasicFeature(obj, node, stream)
            
            epochs = obj.getEpochs(node);
            n = numel(epochs);
            data = epochs(1).getResponse(stream);
            response = zeros(n, numel(data));
            
            response(1, :) = data;
            for i = 2 : n
                data = epochs(i).getResponse(stream);
                response(i, :) = data;
            end
        end
        
        function epochs = getEpochs(obj, node)
            
            if obj.nodeManager.isAnalysisOnline()
                epochs = obj.epochStream;
                return
            end
            % If the epoch Indices are not present in the dataset it will
            % throw an error
            epochs = obj.epochStream(node.epochIndices);
        end
    end
    
    methods (Static)
        
        function featureExtractor = create(template)
            
            import sa_labs.analysis.*;
            parentClass =  core.FeatureExtractor.CLASS;
            class = template.extractorClazz;
            constructor = str2func(class);
            featureExtractor = constructor();
            parentClasses = superclasses(featureExtractor);
            
            if ~ (isa(featureExtractor, parentClass) || numel(parentClasses) > 1 && strcmp(parentClass, parentClasses{end - 1}))
                throw(app.Exceptions.MISMATCHED_EXTRACTOR_TYPE.create());
            end
        end
    end
end
