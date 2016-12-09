classdef SimpleFeatureExtractor < sa_labs.analysis.core.FeatureExtractor
    
    methods (Access = protected)
        
        function stream = getDefaultStream(obj, node)
            if strcmp(node.splitParameter, 'stream')
                stream = node.splitValue;
            else
                % Todo iterate from epochs and select the first device
                % stream
                stream = 'Amp1';
            end
        end
    end
    
end

