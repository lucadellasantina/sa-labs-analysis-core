classdef SimpleFeatureExtractor < sa_labs.analysis.core.FeatureExtractor
    
    methods (Access = protected)
        
        function stream = getDefaultStream(obj, node)
            if strcmp(node.splitParameter, 'stream')
                stream = node.splitValue;
            else
                stream = 'Amp1';
            end
        end
    end
    
end

