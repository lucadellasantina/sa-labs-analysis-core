classdef FeatureExtractor < handle
    
    methods(Abstract)
        extract(obj, data)
        plot(obj)
    end
end

