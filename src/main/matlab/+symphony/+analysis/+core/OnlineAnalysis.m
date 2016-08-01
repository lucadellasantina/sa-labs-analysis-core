classdef OnlineAnalysis < symphony.analysis.core.Analysis
    
    properties(Transient)
        epochStream
    end
    
    methods
        
        function buildTree(obj)
        end
        
        
        function delegateFeatureExtraction(obj, extractors, splitParameters)
            for i = 1 : numel(extractors)
                extractor = extractors(i);
                extractor.epochIterator = @() obj.epochStream;
                extractor.extract(splitParameters);
            end
        end
    end
end

