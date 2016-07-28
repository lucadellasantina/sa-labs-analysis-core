classdef OnlineAnalysis < symphony.analysis.core.Analysis
    
    properties(Transient)
        epochStream
    end
    
    methods
        
        function buildTree(obj)
        end
        
        
        function createFeature(obj, extractors, splitParameters)
            for i = 1 : numel(extractors)
                extractor = extractors(i);
                extractor.epochHandler = @(device, index) obj.epochStream.response(device);
                extractor.extract(splitParameters);
            end
        end
    end
end

