classdef OnlineAnalysis < sa_labs.analysis.core.Analysis
    
    properties(Transient)
        epochStream
    end
    
    methods(Access = protected)
        
        function buildTree(obj)
        end
        
        function setEpochIterator(obj)
        end
        
        function extractFeatures(obj)
        end
    end
end

