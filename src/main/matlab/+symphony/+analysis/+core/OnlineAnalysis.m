classdef OnlineAnalysis < symhpony.analysis.core.Analysis
    
    properties(Transient)
        epochStream
    end
    
    methods
        
        function buildTree(obj)
        end
        
        
        function createFeature(obj, builders, splitParameters)
            for i = 1 : numel(builders)
                builder = builders(i);
                builder.epochHandler = @(device, index) obj.epochStream.response(device);
                builder.build(splitParameters);
            end
        end
    end
end

